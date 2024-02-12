# Bash WEBP to GIF

**EN** | [RU](README_RU.md)

## Description

This docker-container allows you to convert `*.webp` or `*.webm` images to `*.gif` (with animation and transparency preserved).

Solution based on:

- [Solution via `anim_dump`](https://askubuntu.com/questions/1140873/how-can-i-convert-an-animated-webp-to-a-webm);
- [About `ldconfig`](https://stackoverflow.com/questions/12045563/cannot-load-shared-library-that-exists-in-usr-local-lib-fedora-x64/12057372#12057372);
- [Building `libwebp`](https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md).

## Requirements

- Docker and Docker Compose.

## Usage

1. Clone the repository:

    ```bash
    git clone https://github.com/Nikolai2038/bash-webp-to-gif.git
    cd bash-webp-to-gif
    ```

2. Now you can pull image from DockerHub or build it yourself:

   - Pull:

      ```bash
      docker-compose pull
      ```
   
   - Build it yourself (see `./Dockerfile` on how it will be built):
   
      ```bash
      docker-compose build
      ```

3. Put your `.webp` or `.webm` images inside `data` folder (you can create subfolders - all will be ignored in GIT, except `examples` directory)
4. Now you can start the container (the `./data` folder will be mounted):

   ```bash
   docker-compose up --rm
   ```
   
   Inside the container you can execute scripts:
   
   - for a specific file:

       ```bash
       ./convert_one.sh <file path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
       ```

   - for all files in a specific directory:

       ```bash
       ./convert_all_in_dir.sh <directory path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
       ```

## Example

1. There is example file `01_girl.webp` in the `./data/examples` directory.
2. Let's generate `gif` with transparency enabled:

    ```bash
    ./convert_one.sh ./data/examples/01_girl.webp 1 1
    ```

    After some execution the `./data/examples/01_girl.gif` image will be generated:

    ![output gif image](./.readme_images/01_girl_transparency.gif)

3. Rename `01_girl.gif` to `01_girl_transparency.gif` so script won't override it later.
4. Let's run script again, but with transparency disabled now:

    ```bash
    ./convert_one.sh ./data/examples/01_girl.webp 0 1
    ```

    New `01_girl.gif` image will be generated:

    ![output gif image](./.readme_images/01_girl_no_transparency.gif)

    As we can see, all transparency pixels are now black!

5. Rename result image to `01_girl_no_transparency.gif`.

## Contribution

Feel free to contribute via [pull requests](https://github.com/Nikolai2038/bash-webp-to-gif/pulls) or [issues](https://github.com/Nikolai2038/bash-webp-to-gif/issues)!
