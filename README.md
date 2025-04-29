# 🐍 Retro Snake Game in x86/x88 Assembly

A classic Snake game implemented in x86/x88 assembly language, designed to run as a DOS COM file. This project demonstrates low-level programming with direct hardware access for graphics and input handling.

Features
🕹️ Classic snake gameplay with growing mechanics

🎨 Simple but effective graphical display

⏱️ Frame-rate control via delay loops

🍎 Random apple generation

📊 Score tracking

🔄 Game restart functionality

Technical Details
Language: x88 Assembly (NASM/MASM/TASM compatible)

Platform: DOS (or DOSBox for modern systems)

Graphics: Direct BIOS video mode access (Mode 13h)

Input: BIOS keyboard interrupt handling

Memory: COM file format (64KB limit)

# How to Run
Install DOSBox on your system

Assemble the code with:

tasm snake.asm
tlink /t snake.obj
Run in DOSBox:

mount c: /path/to/snake
c:
snake.com
Controls
Arrow Keys: Change snake direction

1: Restart game after game over

0: Exit game

# Code Structure
plaintext
snake.asm
├── Data Section
│   ├── Game state variables
│   ├── Snake segment array
│   ├── Game board matrices
│   └── Text messages
├── Main Game Loop
│   ├── Movement handling
│   ├── Collision detection
│   └── Rendering
├── Subroutines
│   ├── Input handling
│   ├── Graphics rendering
│   ├── Random number generation
│   └── Game logic
└── Initialization/Cleanup
# Technical Highlights
Direct hardware access via BIOS interrupts

Efficient memory management for game state

Custom random number generator

Position-based collision system

Stack-based parameter passing

# Requirements
DOS environment (or DOSBox)

Turbo Assembler (NASM/TASM) or compatible

x86/x88 compatible processor

# Future Improvements
Add difficulty levels

Implement high score tracking

Add sound effects

Create build scripts for easy compilation

# Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

# License
MIT
# Developers
AzibNaeem and Awais-Bin-Abbas

Happy coding! 🚀 Let the retro gaming begin!
