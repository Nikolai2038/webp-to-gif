# bash-webp-to-gif

Bash-script to convert `*.webp` or `*.webm` images to `*.gif` (with animation and transparency preserved).

## Requirements

- Linux (WSL);
- `ffmpeg` and `gifsicle` packages (they will be installed automatically, if not already installed).

## Usage

1. Clone the repository inside Linux machine or WSL.

2. Run main script:

    - for a specific file:

    ```bash
    ./convert_one.sh <file_path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
    ```

    - for all files in a specific directory:

    ```bash
    ./convert_all_in_dir.sh <directory_path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
    ```

## Example

1. There is example file `girl.webp` in the `./data/examples` directory.

2. Let's generate `gif` with transparency enabled:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 1 1
    ```

    After some execution the `./data/examples/girl.gif` image will be generated:

    ![output gif image](data/examples/girl_transparency.gif)

    Lets rename `girl.gif` to `girl_transparency.gif` (so script won't override it later)

3. Let's run script again with transparency disabled:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 0 1
    ```

    After some execution new `girl.gif` image will be generated:

    ![output gif image](data/examples/girl_no_transparency.gif)

    As we can see, all transparency pixels are now black!

    We rename result image to `girl_no_transparency.gif`.

## Contribution

Feel free to contribute!
