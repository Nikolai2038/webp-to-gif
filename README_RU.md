# WEBP to GIF

[EN](README.md) | **RU**

## 1. Описание

Данные скрипты позволяют преобразовать `*.webp` или `*.webm` изображения в `*.gif` (с сохранением анимаций и прозрачности).

Решение основано на:

- [Решение при помощи `anim_dump`](https://askubuntu.com/questions/1140873/how-can-i-convert-an-animated-webp-to-a-webm);
- [Про `ldconfig`](https://stackoverflow.com/questions/12045563/cannot-load-shared-library-that-exists-in-usr-local-lib-fedora-x64/12057372#12057372);
- [Сборка `libwebp`](https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md).

Я рекомендую использовать Docker контейнер, но Вы также можете установить все необходимые пакеты на свою систему и выполнять скрипты на ней (смотреть ниже). 

Некоторые примеры файлов взяты из [тикета](https://trac.ffmpeg.org/ticket/4907) для `ffmpeg` (при попытке конвертировать `webp` изображения, внутри которых имеются блоки `ANIM` и `ANMF`).

## 2. Требования

### 2.1. При использовании Docker контейнера

- Docker и Docker Compose.

### 2.2. При использовании прямо своей системы

Docker контейнер основан на Debian, поэтому инструкции ниже будут тоже приведены для Debian.
Смотрите `./Dockerfile` для большей информации.

1. Установить необходимые пакеты:

    ```bash
    sudo apt update && apt install -y \
        gcc make autoconf automake libtool \
        libpng-dev libjpeg-dev libgif-dev libwebp-dev libtiff-dev libsdl2-dev \
        git \
        ffmpeg \
        gifsicle
    ```

2. Склонировать репозиторий `libwebp` и добавить поддержку `anim_dump` в конфигурацию сборки:

    ```bash
    git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && \
    echo "bin_PROGRAMS += anim_dump" >> ./examples/Makefile.am
    ```

3. Сконфигурировать файлы для сборки:

    ```bash
    ./autogen.sh && \
    ./configure
    ```

4. Установить:

    ```bash
    make && \
    sudo make install && \
    echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf && \
    sudo ldconfig
    ```

5. Проверить установку:

    ```bash
    webpinfo -version && \
    anim_dump -version
    ```

6. Удалить склонированный репозиторий:

    ```bash
    cd .. && \
    rm -rf ./libwebp
    ```

## 3. Использование

Для обоих применений нужно:

1. Склонировать репозиторий:

    ```bash
    git clone https://github.com/Nikolai2038/webp-to-gif.git && \
    cd webp-to-gif
    ```

2. Put your `.webp` or `.webm` images inside `data` folder (you can create subfolders - all will be ignored in GIT, except `examples` directory)

### 3.1. При использовании Docker контейнера

1. Загрузить образ из DockerHub или собрать его самостоятельно:

   - Загрузить:

      ```bash
      docker-compose pull
      ```

   - Собрать самостоятельно (смотреть `./Dockerfile`, чтобы понять, как будет собираться контейнер):

      ```bash
      docker-compose build
      ```

2. Запустить контейнер в фоне (содержимое папки репозитория будет примонтировано в контейнер):

   ```bash
   docker-compose up --detach
   ```

3. Теперь Вы можете выполнить скрипты (пути к изображениям должны быть относительными, и находится внутри папки с репозиторием, так как доступ к ним осуществляется из контейнера):

   - Преобразовать указанный файл `webp` в `gif`:

       ```bash
       ./convert_one.sh <путь к файлу> [0|1 - включить прозрачность, по умолчанию 1] [0|1|2 - уровень сжатия, по умолчанию 1]
       ```

   - Преобразовать все файлы `webp` в указанной директории в `gif`:

        ```bash
        ./convert_all_in_dir.sh <путь к директории> [0|1 - включить прозрачность, по умолчанию 1] [0|1|2 - уровень сжатия, по умолчанию 1]
        ```

   - Преобразовать все файлы примеров `webp` (внутри `./data/examples`) в `gif`:

        ```bash
        ./test.sh [0|1 - включить прозрачность, по умолчанию 1] [0|1|2 - уровень сжатия, по умолчанию 1]
        ```

   - Удалить ВСЕ файлы `gif` внутри директории `./data` (рекурсивно):

        ```bash
        ./clear.sh
        ```

   Вы также можете выполнить команду напрямую, но не забывайте использовать скрипты из директории `./scripts`. Например:

    ```bash
    docker-compose exec webp-to-gif bash -c './scripts/convert_one.sh ./data/examples/01_girl.webp 0 1'
    ```

4. Для остановки и удаления контейнера, выполнить:

   ```bash
   docker-compose down
   ```

### 3.2. При использовании прямо своей системы

Просто используйте скрипты из директории `./scripts`, а не из корня репозитория. Аргументы остаются такими же.

## 4. Пример

1. В качестве примеров приведены несколько файлов в папке `./data/examples`, например `01_girl.webp`.
2. Сгенерируем `gif` с сохранением прозрачности:

    ```bash
    ./convert_one.sh ./data/examples/01_girl.webp 1 1
    ```

    После выполнения будет сгенерировано изображение `./data/examples/01_girl.gif`:

    ![output gif image](./.readme_images/01_girl_transparency.gif)

3. Переименуем `01_girl.gif` в `01_girl_transparency.gif`, чтобы повторное выполнение скрипта не перезаписало файл.
4. Запустим скрипт снова, но уже не сохраняя прозрачность:

    ```bash
    ./convert_one.sh ./data/examples/01_girl.webp 0 1
    ```

    Будет сгенерировано новое изображение `01_girl.gif`:

    ![output gif image](./.readme_images/01_girl_no_transparency.gif)

    Как мы видим, все прозрачные пиксели теперь чёрные!

5. Переименуем изображение в `01_girl_no_transparency.gif`.

## 5. Развитие

Не стесняйтесь участвовать в развитии репозитория, используя [pull requests](https://github.com/Nikolai2038/webp-to-gif/pulls) или [issues](https://github.com/Nikolai2038/webp-to-gif/issues)!
