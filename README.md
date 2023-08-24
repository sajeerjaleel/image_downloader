# Image Downloader

A multi-threaded solution for downloading a large number of images given their URLs from a txt file.

## Table of Contents

- [Description](#description)
- [Setup and Usage](#setup-and-usage)
- [Why This is a Good Solution](#why-this-is-a-good-solution)
- [Testing](#testing)
- [Future Improvements](#future-improvements)

## Description

The `image_downloader` script efficiently fetches a set of image URLs and stores them locally. It handles errors, such as invalid URLs or failed downloads, and ensures that even if two images have the same name, they won't overwrite each other due to the unique naming solution implemented.

## Architecture
1. **ImageDownloader Class**:

- Responsible for downloading a single image.
- Uses open-uri to fetch the image and saves it with a unique name to avoid name clashes.
- Handles errors gracefully, ensuring issues like 404s do not halt the entire operation.

2. **BatchDownloader Class**:

- Manages the download of multiple images concurrently.
- Takes advantage of threads to download multiple images in parallel.
- Uses ImageDownloader to download each individual image.

3. **URLReader Class**:

- Extracts image URLs from a given file.
- Helps in maintaining a clean separation between data retrieval and image downloading functionalities.

4. **Configuration Class**:

- Manages all the configurations required for the download process.
- Allows users to customize the concurrency.

5. **Logger Class**:

- Provides an in-built logging mechanism.
- Aids in recording every significant event or error, facilitating smoother audit and debugging processes.


## Setup and Usage

1. Clone the repository:

2. Change directory: `cd image_downloader`

3. Run the script: `lib/downloader.rb`

## Testing

Unit test and end-end test covering most of the scenarios are also added. To run tests: `rspec`

## Why This is a Good Solution

1. ***Modularity & Clean Code Organization***: The code is structured with well-defined classes and methods, each with a clear purpose. This separation of concerns facilitates easier future changes, debugging, and extension.

- **Class Extraction**: Breaking the solution into dedicated classes, such as ImageDownloader and BatchDownloader, allows for improved readability and maintainability. For instance, if in the future, the way we download a single image needs to change, modifications can be localized to the ImageDownloader class without affecting the batch process.
- **Extensibility**: Each class is designed to be open for extension but closed for modification. This means adding new features or behaviors in the future (like different ways to generate unique file names or various logging strategies) can be done without altering existing, tested code.
2. ***Efficiency***: The use of multi-threading ensures that multiple images can be downloaded concurrently, speeding up the process for large sets of URLs.
3. ***Error Handling***: Comprehensive error handling ensures that the script gracefully manages unexpected situations, such as 404 errors, without halting the entire process.
4. ***Unique Naming***: A unique name generator ensures no file overwrites, even if two or more image URLs point to images with the same name.
5. ***Scalability***: The script is designed to handle large sets of URLs, making it scalable for larger tasks.
6. ***Logging***: Integrated logging helps in troubleshooting and audit purposes. The logs are also added to log file.
7. ***Configurations***: The Configuration allows user to select the concurrency level. Configuration also allow users to select the image folder and log file path


## Future Improvements

1. Integrate with a database to track the status of each URL.
2. Implement retries for URLs that fail to download due to network errors.
3. Scheduling the operation.
