import json
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
EXAMPLES = ROOT / "examples"


class MinioFixtureContracts(unittest.TestCase):
    def test_lifecycle_json_is_valid_and_scoped_to_staging_prefix(self):
        payload = json.loads((EXAMPLES / "04-versioning-lifecycle" / "lifecycle.json").read_text(encoding="utf-8"))
        rules = payload["Rules"]
        self.assertEqual(len(rules), 1)
        self.assertEqual(rules[0]["Filter"]["Prefix"], "staging/")
        self.assertEqual(rules[0]["Expiration"]["Days"], 30)
        self.assertEqual(rules[0]["Status"], "Enabled")


class MinioScriptSafetyContracts(unittest.TestCase):
    def test_all_scripts_fail_fast(self):
        scripts = sorted(EXAMPLES.rglob("*.sh"))
        self.assertEqual(len(scripts), 4)
        for script in scripts:
            with self.subTest(script=script.relative_to(ROOT)):
                self.assertIn("set -euo pipefail", script.read_text(encoding="utf-8"))

    def test_source_build_requires_credentials_and_binds_loopback(self):
        script = (EXAMPLES / "01-source-build" / "build.sh").read_text(encoding="utf-8")
        self.assertIn('MINIO_ROOT_USER:?set MINIO_ROOT_USER', script)
        self.assertIn('MINIO_ROOT_PASSWORD:?set MINIO_ROOT_PASSWORD', script)
        self.assertNotIn("CHANGEME", script)
        self.assertIn("--address 127.0.0.1:9000", script)
        self.assertIn("--console-address 127.0.0.1:9001", script)
        self.assertIn("trap cleanup EXIT", script)
        self.assertIn("for _ in $(seq 1 30)", script)

    def test_mc_credentials_use_temporary_config(self):
        for relative in (
            "examples/02-bucket-setup/setup.sh",
            "examples/03-presigned/presigned.sh",
            "examples/04-versioning-lifecycle/apply.sh",
        ):
            with self.subTest(script=relative):
                script = (ROOT / relative).read_text(encoding="utf-8")
                self.assertIn("mc --config-dir", script)
                self.assertIn("mktemp -d", script)
                self.assertIn("trap 'rm -rf", script)

    def test_presigned_roundtrip_verifies_bytes_and_uses_truthful_fixture_name(self):
        script = (EXAMPLES / "03-presigned" / "presigned.sh").read_text(encoding="utf-8")
        self.assertIn("demo.txt", script)
        self.assertNotIn("demo.tif", script)
        self.assertIn("cmp", script)
        self.assertIn("--fail-with-body", script)
        self.assertNotIn("| head -c", script)

    def test_lifecycle_fixture_path_is_script_relative(self):
        script = (EXAMPLES / "04-versioning-lifecycle" / "apply.sh").read_text(encoding="utf-8")
        self.assertIn('"$SCRIPT_DIR/lifecycle.json"', script)


if __name__ == "__main__":
    unittest.main()
