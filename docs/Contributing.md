---
title: Contributing
parent: Home
nav_order: 3
---

[Source Contributing Guide](https://github.com/Celerium/Celerium.Auvik/blob/main/.github/CONTRIBUTING.md)

---

# How to contribute to this module

> Please note: As a loose rule any pull requests for general code cleanup will generally be merged when a new version is released. I have a limited number of hours per week to review and test pull requests. I will do my best to test pull requests within a reasonable time frame, but no guarantees can be made.

## **Did you find a bug?**

* **Ensure the bug was not already reported** by searching on GitHub under [Issues](https://github.com/Celerium/Celerium.Auvik/issues).

* If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/Celerium/Celerium.Auvik/issues/new/choose).
  * Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

## **Did you write a patch that fixes a bug?**

* [ ] Ensure the pull request description clearly describes the problem and solution.

If the feature is accepted and I have time to test, the pull request will be approved.

## **Do you intend to add a new feature or change an existing one?**

* Suggest your change by creating a GitHub issue tagged with "Enhancement"

* Create a branch and start working on your new feature, following feedback from the community.

* Once the new feature is ready,

  * [ ] Update any documentation if needed
  * [ ] Submit a pulling request to the **main** branch

If the feature is accepted and I have time to test, the pull request will be approved.

## **Building, testing, and generated code**

The public functions of this module are **generated** from the Auvik v1 OpenAPI spec ([docs/Auvik-v1.json](https://github.com/Celerium/Celerium.Auvik/blob/main/docs/Auvik-v1.json)). The CI workflow regenerates them and fails when the committed files are different.

* **Do not edit the generated public functions by hand** (`Celerium.Auvik/Public/**`, the export lists of `Celerium.Auvik.psd1`, and `docs/endpoints.csv`). Change `build/New-PublicFunctions.ps1` or the spec instead and then run it:

  ```powershell
  ./build/New-PublicFunctions.ps1
  ```

* The spec can be refreshed & compared to the online version with `build/Get-AuvikSpec.ps1` & `build/Compare-AuvikSpec.ps1`.
* The private functions (`Celerium.Auvik/Private/**`), the build scripts, the tests, and the examples are maintained by hand.
* All parameters & variables use PascalCase.
* Install the build prerequisites once, then build and test the module:

  ```powershell
  ./build/Install-Prerequisites.ps1
  ./build/Invoke-ModuleBuild.ps1 -Version 2.0.0
  ./build/Invoke-PesterTests.ps1 -Version 2.0.0 -BuildTarget notBuilt
  ./build/Invoke-PesterTests.ps1 -Version 2.0.0 -BuildTarget built
  ```

* The module supports **Windows PowerShell 5.1** and **PowerShell 7+** on Windows, Linux, and macOS. Run the tests on both Windows PowerShell 5.1 (`powershell.exe`) and PowerShell 7+ (`pwsh`) before submitting a pull request. The GitHub Actions CI workflow runs them on Windows PowerShell 5.1, Windows PowerShell 7+, Linux, & macOS.
* The `Live` tests make read-only requests against a real Auvik tenant and are skipped by default. Never commit credentials; use the `AUVIK_USERNAME`, `AUVIK_API_KEY`, & `AUVIK_SITE_NAME` environment variables if you run them.
* The markdown documentation in `docs/` is generated from the module help & the tracking CSV with `build/Invoke-HelpContent.ps1`. Update the comment based help of a function (or the generator) instead of the markdown.

Thanks! :heart:

---

> Based off of the Ruby on Rails project [contribution guide](https://github.com/rails/rails/blob/master/CONTRIBUTING.md).
