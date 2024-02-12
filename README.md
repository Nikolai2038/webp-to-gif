# WEBP to GIF

**EN** | [RU](README_RU.md)

## 1. Description

These scripts allows you to convert `*.webp` or `*.webm` images to `*.gif` (with animation and transparency preserved).

Solution based on:

- [Solution via `anim_dump`](https://askubuntu.com/a/1141049);
- [About `ldconfig`](https://stackoverflow.com/questions/12045563/cannot-load-shared-library-that-exists-in-usr-local-lib-fedora-x64/12057372#12057372);
- [Building `libwebp`](https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md).

I suggest you to use Docker container, but you can still install all required packages and execute scripts in your system too (see below).

Some example files was taken from [ticket](https://trac.ffmpeg.org/ticket/4907) on `ffmpeg` (when attempt to convert `webp` images with `ANIM` and `ANMF` blocks inside them).

## 2. Requirements

### 2.1. Using Docker container

- Docker and Docker Compose.

### 2.2. Using raw system

The Docker container was based on Debian, so instructions below will be for Debian too.
See `./Dockerfile` for more info.

1. Install required packages:

    ```bash
    sudo apt update && apt install -y \
        gcc make autoconf automake libtool \
        libpng-dev libjpeg-dev libgif-dev libwebp-dev libtiff-dev libsdl2-dev \
        git \
        ffmpeg \
        gifsicle
    ```

2. Clone `libwebp` repository and add `anim_dump` support to build configuration:

    ```bash
    git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && \
    echo "bin_PROGRAMS += anim_dump" >> ./examples/Makefile.am
    ```

3. Configure build files:

    ```bash
    ./autogen.sh && \
    ./configure
    ```

4. Install:

    ```bash
    make && \
    sudo make install && \
    echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf && \
    sudo ldconfig
    ```

5. Check installation:

    ```bash
    webpinfo -version && \
    anim_dump -version
    ```

6. Remove cloned repository:

    ```bash
    cd .. && \
    rm -rf ./libwebp
    ```

## 3. Usage

For both usages you need to:

1. Clone the repository:

    ```bash
    git clone https://github.com/Nikolai2038/webp-to-gif.git && \
    cd webp-to-gif
    ```

2. Put your `.webp` or `.webm` images inside `data` folder (you can create subfolders - all will be ignored in GIT, except `examples` directory)

### 3.1. Using Docker Container

1. Pull image from DockerHub or build it yourself:

    - Pull:

       ```bash
       docker-compose pull
       ```

    - Build it yourself (see `./Dockerfile` on how it will be built):

       ```bash
       docker-compose build
       ```

2. Start the container in the background (the repository root folder will be mounted):

   ```bash
   docker-compose up --detach
   ```

3. Now you can execute scripts (the paths to images must be relative and be inside repository folder, since they are accessed from the container):

    - Convert specific `webp` file to `gif`:

        ```bash
        ./convert_one.sh <file path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
        ```

   - Convert all `webp` files in a specific directory to `gif`:

        ```bash
        ./convert_all_in_dir.sh <directory path> [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
        ```

   - Convert all `webp` example files (inside `./data/examples`) to `gif`:

        ```bash
        ./test.sh [0|1 - enable transparency, default is 1] [0|1|2 - compression level, default is 1]
        ```
     
   - Remove ALL `gif` files inside `./data` directory (recursively):

        ```bash
        ./clear.sh
        ```

    You can also execute raw command, but remember to use scripts inside `./scripts` directory. For example:
    
    ```bash
    docker-compose exec webp-to-gif bash -c './scripts/convert_one.sh ./data/examples/01_girl.webp 0 1'
    ```

4. To stop and remove container, use:

   ```bash
   docker-compose down
   ```

### 3.2. Using raw system

Just use scripts in `./scripts` directory, not in repository's root. The arguments are the same.

## 4. Example

1. There are several example files in the `./data/examples` directory, for example, `01_girl.webp`.
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

## 5. Contribution

Feel free to contribute via [pull requests](https://github.com/Nikolai2038/webp-to-gif/pulls) or [issues](https://github.com/Nikolai2038/webp-to-gif/issues)!
