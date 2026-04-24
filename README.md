
***

<div align="center">
  <h1>🎵 MaestroLang</h1>
  <p><b>An Algorithmic Music Compiler</b></p>
  
  <img src="https://img.shields.io/badge/Language-C%20%7C%20Python-orange?style=for-the-badge" alt="Language">
  <img src="https://img.shields.io/badge/Parser-Flex%20%26%20Bison-blue?style=for-the-badge" alt="Parser">
  <img src="https://img.shields.io/badge/Platform-Docker%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows-lightgray?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/Build-Passing-brightgreen?style=for-the-badge" alt="Build">
</div>

<br>

**MaestroLang** is a custom Domain-Specific Language (DSL) and compiler built from scratch. It translates human-readable, algorithmic music syntax into intermediate Python code, and subsequently generates fully playable binary MIDI audio files.

Unlike traditional toy compilers, MaestroLang utilizes **Source-to-Source Compilation (Transpilation)**, dynamic Syntax-Directed Translation (SDT), and an embedded C-based Symbol Table.

---

## 🌊 The Compilation Pipeline

```text
 ┌──────────────┐   Lexical   ┌──────────────┐   Syntax / SDT   ┌──────────────┐   music21    ┌──────────────┐
 │ Source Code  │  Analysis   │ Token Stream │    Analysis      │ Python Code  │  Generation  │ MIDI Audio   │
 │ (song.mstr)  ├────────────►│ (Flex / C)   ├─────────────────►│ (Bison / C)  ├─────────────►│ (.mid file)  │
 └──────────────┘             └──────────────┘                  └──────────────┘              └──────────────┘
```

---

## 📑 Table of Contents
1. [Key Features](#1-key-features)
2. [Language Syntax](#2-language-syntax)
3. [Quick Start (Docker / Cross-Platform)](#3-quick-start-docker--cross-platform)
4. [Local Build (macOS / Linux)](#4-local-build-macos--linux)
5. [Local Build (Windows via WSL)](#5-local-build-windows-via-wsl)
6. [Project Structure](#6-project-structure)

---

## 1. Key Features
* **Turing-Complete Constructs:** Supports bounded `Repeat` loops and reusable Macros (`Define`) to algorithmically structure music.
* **Semantic Analysis & Symbol Table:** A built-in C memory structure tracks identifiers. It prevents duplicate macro declarations, catches undeclared macros, and enforces real-world physics bounds (e.g., rejecting Tempos > 300 BPM).
* **Dynamic Python Indentation:** Calculates Python's strict spacing requirements dynamically on-the-fly during Bison parsing, completely avoiding the need for a bulky Abstract Syntax Tree (AST).
* **Abstracted Execution:** The user runs one command (`maestro song.mstr`). The C-executable invokes the Python environment behind the scenes via a `system()` call, instantly returning the final audio file.

---

## 2. Language Syntax
MaestroLang uses a clean, C-style syntax designed specifically for musical composition. Save your code as a `.mstr` file.

```javascript
Track "MySong" {
    Tempo 120; // Set the track speed (BPM)

    /* Define a reusable musical phrase (Macro) */
    Define Hook {
        Play C5(eighth);
        Play D5(eighth);
        Play E5(quarter);
    }

    /* Loop the chords and the macro */
    Repeat 4 {
        PlayMacro Hook;
        Chord [C4, E4, G4](half);
    }
}
```

---

## 3. Quick Start (Docker / Cross-Platform)
Because C-executables are architecture-dependent, the absolute easiest way to run MaestroLang on **Windows, macOS, or Linux** without installing GCC or Python is via Docker.

### Build the Engine
Clone the repository and build the Docker image:
```bash
git clone https://github.com/YOUR_USERNAME/MaestroLang.git
cd MaestroLang
docker build -t maestrolang .
```

### Compile Your Music
Create a `song.mstr` file in your directory, then run the Docker container. Volume mapping automatically drops the generated audio file right back onto your computer.

**macOS / Linux:**
```bash
docker run --rm -v $(pwd):/work maestrolang song.mstr
```
**Windows PowerShell:**
```powershell
docker run --rm -v ${PWD}:/work maestrolang song.mstr
```

---

## 4. Local Build (macOS / Linux)
If you wish to compile the engine natively on your local machine:

**Prerequisites:**
* `gcc` and `make`
* `flex` and `bison`
* `python3` (with `music21` library: `pip install music21`)

**Build & Install:**
```bash
git clone https://github.com/YOUR_USERNAME/MaestroLang.git
cd MaestroLang

# Build the compiler executable
make clean
make

# Move executable to global path (Optional)
sudo cp maestro /usr/local/bin/
```

**Usage:**
```bash
maestro my_song.mstr
```
*Output: `Compilation successful! Generating audio behind the scenes...`*<br>
A `generated_audio.mid` file will instantly appear in your directory.

---

## 5. Local Build (Windows via WSL)
Windows does not natively support Flex, Bison, or GCC. The industry-standard way to compile this project natively on Windows is by using **WSL (Windows Subsystem for Linux)**.

**Step 1: Enable WSL**
Open PowerShell as Administrator and run:
```powershell
wsl --install
```
*(Restart your computer if prompted, then open the newly installed "Ubuntu" terminal app).*

**Step 2: Install Compiler Tools**
Inside the Ubuntu terminal, install the required C and Python libraries:
```bash
sudo apt update
sudo apt install gcc make flex bison python3 python3-pip
pip3 install music21
```

**Step 3: Build and Run**
Now, you can compile and run MaestroLang exactly like a Linux environment:
```bash
git clone https://github.com/YOUR_USERNAME/MaestroLang.git
cd MaestroLang
make clean && make
./maestro my_song.mstr
```
You can access the generated `.mid` file through the Windows File Explorer by typing `explorer.exe .` in your Ubuntu terminal!

---

## 6. Project Structure

```text
MaestroLang/
├── lexer.l              # Lexical Analyzer (Regex, Token definitions)
├── parser.y             # Parser, Context-Free Grammar, SDT & Symbol Table
├── Makefile             # C-toolchain automation
├── Dockerfile           # OS-independent container configuration
├── pop.mstr             # Sample MaestroLang source code
└── README.md            # Project documentation
```

<br>

---
<div align="center">
  <i>Built with ❤️ for the love of Code and Music</i>
</div>
