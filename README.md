# Bash WEBP to GIF

**EN** | [RU](README_RU.md)

## Description

This script allows you to convert `*.webp` or `*.webm` images to `*.gif` (with animation and transparency preserved).

## Requirements

- Linux or WSL;
- Bash;
- `ffmpeg` and `gifsicle` apt-packages installed (they will be installed automatically, if not already installed).

## Usage

1. Clone the repository:

    ```bash
    git clone https://github.com/Nikolai2038/bash-webp-to-gif.git
    cd bash-webp-to-gif
    ```

2. Run main script:

    - for a specific file:

        ```bash
        ./convert_one.sh <file path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
        ```

    - for all files in a specific directory:

        ```bash
        ./convert_all_in_dir.sh <directory path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
        ```

## Example

1. There is example file `girl.webp` in the `./data/examples` directory.
2. Let's generate `gif` with transparency enabled:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 1 1
    ```

    After some execution the `./data/examples/girl.gif` image will be generated:

    ![output gif image](data/examples/girl_transparency.gif)

3. Rename `girl.gif` to `girl_transparency.gif` so script won't override it later.
4. Let's run script again, but with transparency disabled now:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 0 1
    ```

    New `girl.gif` image will be generated:

    ![output gif image](data/examples/girl_no_transparency.gif)

    As we can see, all transparency pixels are now black!

5. Rename result image to `girl_no_transparency.gif`.

## Contribution

Feel free to contribute via [pull requests](https://github.com/Nikolai2038/bash-webp-to-gif/pulls) or [issues](https://github.com/Nikolai2038/bash-webp-to-gif/issues)!
