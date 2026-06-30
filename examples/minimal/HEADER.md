<!--
  Header for the minimal example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
-->
# Minimal example

The smallest valid call to this module: required inputs only. The environment comes from the
Terraform workspace (`terraform.workspace`), not a variable. Run it with `just e2e minimal`, which
applies the stack then always destroys it.
