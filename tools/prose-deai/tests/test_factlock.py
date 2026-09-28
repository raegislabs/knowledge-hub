import contextlib
import importlib.util
import io
import sys
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "prose-factlock.py"
SPEC = importlib.util.spec_from_file_location("prose_factlock", MODULE_PATH)
FACTLOCK = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(FACTLOCK)


class FactLockTests(unittest.TestCase):
    def run_main(self, before_text, after_text, *flags):
        with tempfile.TemporaryDirectory() as temp_dir:
            before = Path(temp_dir) / "before.md"
            after = Path(temp_dir) / "after.md"
            before.write_text(before_text, encoding="utf-8")
            after.write_text(after_text, encoding="utf-8")
            previous_argv = sys.argv
            sys.argv = [str(MODULE_PATH), str(before), str(after), *flags]
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    return FACTLOCK.main()
            finally:
                sys.argv = previous_argv

    def test_bare_small_integer_is_a_fact(self):
        extracted = FACTLOCK.facts("The sample contains 42 signed contracts.")
        self.assertEqual(extracted["num:42"], 1)

    def test_changed_bare_integer_fails_strict_check(self):
        result = self.run_main(
            "The sample contains 42 signed contracts.",
            "The sample contains 43 signed contracts.",
            "--strict-added",
        )
        self.assertEqual(result, 1)

    def test_ordered_list_markers_are_not_facts(self):
        extracted = FACTLOCK.facts(
            "1. First item\n2) Second item\n## 3. Third item\nThe sample has 2 cases."
        )
        self.assertNotIn("num:1", extracted)
        self.assertNotIn("num:3", extracted)
        self.assertEqual(extracted["num:2"], 1)

    def test_new_small_integer_fails_strict_added(self):
        result = self.run_main(
            "The sample is complete.",
            "The sample includes 2 exceptions.",
            "--strict-added",
        )
        self.assertEqual(result, 1)

    def test_unit_restatement_preserves_numeric_core(self):
        result = self.run_main(
            "Conversion improved by 19.5.",
            "Conversion improved by 19.5 points.",
            "--strict-added",
        )
        self.assertEqual(result, 0)

    def test_changed_nonempty_unit_fails(self):
        result = self.run_main(
            "Conversion improved by 19.5%.",
            "Conversion improved by 19.5 points.",
            "--strict-added",
        )
        self.assertEqual(result, 1)

    def test_changed_sign_fails(self):
        result = self.run_main(
            "Demand changed by -5%.",
            "Demand changed by 5%.",
            "--strict-added",
        )
        self.assertEqual(result, 1)

    def test_range_hyphen_is_not_a_negative_sign(self):
        extracted = FACTLOCK.facts("The expected range is 5-10 units.")
        self.assertIn("num:5", extracted)
        self.assertIn("num:10units", extracted)
        self.assertNotIn("num:-10units", extracted)

    def test_restatement_does_not_hide_a_lost_duplicate(self):
        result = self.run_main(
            "The two readings were 19.5 and 19.5.",
            "The reading was 19.5 points.",
            "--strict-added",
        )
        self.assertEqual(result, 1)


if __name__ == "__main__":
    unittest.main()
