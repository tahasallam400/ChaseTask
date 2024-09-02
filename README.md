# ChaseTask

## Overview

This project follows the MVVM (Model-View-ViewModel) architecture pattern and is built using Swift and SwiftUI, ensuring a clean, maintainable, and scalable codebase.

## Features

- **MVVM Architecture:** The project is organized using the MVVM design pattern, separating the business logic, UI, and data management into distinct components.
- **Modular Design:** The project is divided into various modules such as `Models`, `ViewModel`, `Views`, `Services`, and `Utilities`.
- **Unit and UI Testing:** Includes test targets (`ChaseTaskTests` and `ChaseTaskUITests`) to ensure the app's functionality is reliable and bug-free.
- **SwiftUI:** Utilizes SwiftUI for creating a modern and responsive user interface.
- **Combine:** Implements Combine for reactive programming and managing asynchronous tasks.

## Project Structure

- **Models:** Contains the data models used in the application.
- **ViewModel:** Holds the business logic and manages data between the views and the models, adhering to the MVVM pattern.
- **Views:** Includes the SwiftUI views, which define the user interface.
- **Services:** Contains network and other services required for the application.
- **Utilities:** A collection of utility functions and extensions used across the project.

## Installation

To set up and run the project locally, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/tahasallam400/ChaseTask.git
    ```
2. Navigate to the project directory:
    ```bash
    cd ChaseTask/ChaseTask
    ```
3. Open the project in Xcode:
    ```bash
    open ChaseTask.xcodeproj
    ```
4. Ensure you have the necessary dependencies and SDK versions installed.
5. Build and run the project using the Xcode IDE.

## Testing

To run the tests included in the project:

1. Open the `ChaseTask.xcodeproj` in Xcode.
2. Select the `ChaseTaskTests` or `ChaseTaskUITests` target.
3. Press `Command + U` to run all tests or use the Xcode interface to run specific tests.

## Contributing

If you wish to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Contact

For any inquiries or issues, feel free to reach out to [your contact information].
