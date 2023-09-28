# Bash WEBP to GIF

[EN](README.md) | **RU**

## Описание

Данный скрипт позволяет преобразовать `*.webp` или `*.webm` изображения в `*.gif` (с сохранением анимаций и прозрачности).

## Требования

- Linux или WSL;
- Bash;
- `ffmpeg` и `gifsicle` apt-пакеты (они будут установлены автоматически, если ещё не установлены).

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

1. В качестве примера рассмотрим файл `girl.webp` в папке `./data/examples`.
2. Сгенерируем `gif` с сохранением прозрачности:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 1 1
    ```

    После выполнения будет сгенерировано изображение `./data/examples/girl.gif`:

    ![output gif image](data/examples/girl_transparency.gif)

3. Переименуем `girl.gif` в `girl_transparency.gif`, чтобы повторное выполнение скрипта не перезаписало файл.
4. Запустим скрипт снова, но уже не сохраняя прозрачность:

    ```bash
    ./convert_one.sh ./data/examples/girl.webp 0 1
    ```

    Будет сгенерировано новое изображение `girl.gif`:

    ![output gif image](data/examples/girl_no_transparency.gif)

    Как мы видим, все прозрачные пиксели теперь чёрные!

5. Переименуем изображение в `girl_no_transparency.gif`.

## Развитие

Не стесняйтесь участвовать в развитии репозитория, используя [pull requests](https://github.com/Nikolai2038/bash-webp-to-gif/pulls) или [issues](https://github.com/Nikolai2038/bash-webp-to-gif/issues)!
