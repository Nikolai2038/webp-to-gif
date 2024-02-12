# Bash WEBP to GIF

[EN](README.md) | **RU**

## Описание

Данный docker-контейнер позволяет преобразовать `*.webp` или `*.webm` изображения в `*.gif` (с сохранением анимаций и прозрачности).

Решение основано на:

- [Решение при помощи `anim_dump`](https://askubuntu.com/questions/1140873/how-can-i-convert-an-animated-webp-to-a-webm);
- [Про `ldconfig`](https://stackoverflow.com/questions/12045563/cannot-load-shared-library-that-exists-in-usr-local-lib-fedora-x64/12057372#12057372);
- [Сборка `libwebp`](https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md).

## Требования

- Docker и Docker Compose.

## Использование

1. Склонировать репозиторий:

    ```bash
    git clone https://github.com/Nikolai2038/bash-webp-to-gif.git
    cd bash-webp-to-gif
    ```

2. Выполнить сам скрипт:

    - для конкретного файла:

        ```bash
        ./convert_one.sh <путь к файлу> [0|1 - включить прозрачность, по умолчанию 1] [0|1|2 - уровень сжатия, по умолчанию 1]
        ```

    - для всех файлов в конкретной директории:

        ```bash
        ./convert_all_in_dir.sh <путь к директории> [0|1 - включить прозрачность, по умолчанию 1] [0|1|2 - уровень сжатия, по умолчанию 1]
        ```

## Пример

1. В качестве примера рассмотрим файл `01_girl.webp` в папке `./data/examples`.
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

## Развитие

Не стесняйтесь участвовать в развитии репозитория, используя [pull requests](https://github.com/Nikolai2038/bash-webp-to-gif/pulls) или [issues](https://github.com/Nikolai2038/bash-webp-to-gif/issues)!
