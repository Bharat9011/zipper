# Zipper 🤐

**Zipper** is a smart, cross-platform CLI tool built with Dart for zipping and unzipping project folders. It is designed to be developer-friendly, automatically respecting your project's structure and ignore rules.

## ✨ Features

- **Smart Ignoring**: Automatically respects `.gitignore` and uses a custom `.zipignore` to exclude unwanted files (like `node_modules`, `.git`, `build`, etc.).
- **Auto-Configuration**: If no `.zipignore` exists, `zipper` generates one for you based on your project type and `.gitignore`.
- **Preview Mode**: See exactly what files will be included in your zip before creating it.
- **Cross-Platform**: Works seamlessly on Windows, macOS, and Linux.
- **Built-in Unzip**: Extract zip archives easily without needing external tools.
- **Verbose Logging**: Get detailed feedback on what's happening during the zip/unzip process.

## 🚀 Installation

### From Source
1.  Ensure you have the [Dart SDK](https://dart.dev/get-dart) installed.
2.  Clone this repository.
3.  Navigate to the project directory:
    ```bash
    cd zipper
    ```
4.  Compile the executable:
    ```bash
    dart compile exe bin/zipper.dart -o build/zipper.exe
    ```
5.  (Optional) Add the `build` directory to your system's `PATH` to run `zipper` from anywhere.

## 📖 Usage

### Zipping a Project
To zip the current directory:
```bash
zipper zip .
```

To zip a specific folder to a specific output file:
```bash
zipper zip my_project -o my_project_v1.zip
```

**Options:**
- `-o, --output`: Specify the output zip file name.
- `-v, --verbose`: Show detailed output of files being zipped.
- `--dry-run`: Preview files without creating the zip.

### Unzipping an Archive
To extract a zip file:
```bash
zipper unzip archive.zip
```

To extract to a specific directory:
```bash
zipper unzip archive.zip -o output_folder
```

### Previewing
Check what files will be included in the zip without actually creating it:
```bash
zipper preview .
```
*Note: This is equivalent to `zipper zip . --dry-run`.*

### Initializing Configuration
Generate a default `.zipignore` file for your project:
```bash
zipper init
```

## ⚙️ Configuration (.zipignore)

Zipper uses a `.zipignore` file to determine which files to exclude. It works similarly to `.gitignore`.

**Example `.zipignore`:**
```gitignore
# Version Control
.git/
.gitignore

# Dependencies
node_modules/
.dart_tool/
pubspec.lock

# Build Artifacts
build/
*.exe
*.apk

# IDE Settings
.vscode/
.idea/
```

If you don't have a `.zipignore`, `zipper` will automatically create one for you, intelligently copying patterns from your `.gitignore` if it exists.

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License

This project is licensed under the MIT License.
