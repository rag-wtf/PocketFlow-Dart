# PocketFlow-Dart

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
![Coverage](coverage_badge.svg)
[![License: MIT][license_badge]][license_link]

A minimalist LLM framework, ported from Python to Dart.

## 🧩 Core vs Extensions

This library provides two import options:

- **`package:pocketflow/pocketflow.dart`** - Core classes that mirror the [Python PocketFlow](https://github.com/The-Pocket/PocketFlow) implementation
- **`package:pocketflow/pocketflow_extensions.dart`** - Dart-specific convenience extensions

For most use cases, start with the core library. See [EXTENSIONS.md](lib/EXTENSIONS.md) for details on the additional Dart-specific patterns available in the extensions library.

## 💻 Installation

**❗ In order to start using `pocketflow` package you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add pocketflow
```

## 🧑‍💼 Contributing

Contributions are welcome! Please check out the unimplemented features or issues on the repository, and feel free to open a pull request.
For more information, please see the [contribution guide](CONTRIBUTING.md).

<a href="https://github.com/rag-wtf/PocketFlow-Dart/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=rag-wtf/PocketFlow-Dart" />
</a>

## 🙏 Acknowledgements

This package was created using the following agentic coding tools:

- [Spec-Kit](https://github.com/github/spec-kit)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- [Google Jules](https://jules.google)
- [Augment Code](https://www.augmentcode.com/)

## 📔 License

This project is licensed under the terms of the MIT license.

## 🗒️ Citation

If you utilize this package, please consider citing it with:

```
@misc{pocketflow,
  author = {Lim Chee Kin},
  title = {PocketFlow-Dart: A Dart Port of PocketFlow Python},
  year = {2025},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/rag-wtf/PocketFlow-Dart}},
}
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows

