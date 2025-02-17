# Godot Resource Editor Tool

A simple yet powerful resource editor tool for Godot 4, designed to help game designers create and manage resource (.tres) files without coding knowledge. This tool streamlines the workflow between designers and developers by providing a user-friendly interface for resource creation.

## Features

- Create, load, and manage game resource files (.tres)
- User-friendly interface for non-technical team members
- Support for basic resource properties:
  - Item name
  - Item description
  - Item power value
  - Item image (supports PNG, JPG, JPEG)
- Clear visual feedback with image preview
- Automatic file handling and organization
- Works directly in the game's executable directory

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/[your-username]/godot-resource-editor
    ```

2. Open the project in Godot 4
3. Run the editor scene
4. Export the project if you want to distribute it to your team

## Usage

1. **Creating a New Resource**
   - Fill in the item details (name, description, power)
   - Optionally add an image using the image selection button
   - Click "Save" and choose a location for your .tres file

2. **Loading Existing Resources**
   - Click "Load" and select an existing .tres file
   - The tool will populate all fields with the saved data

3. **Deleting Resources**
   - Click "Delete" and select the .tres file you want to remove
   - Confirm the deletion

## Project Structure
├── scenes/
│   └── main_editor.tscn
├── scripts/
│   ├── item_editor.gd
│   └── item_resource.gd
├── export_presets.cfg
└── project.godot

## Future Plans

- [ ] Support for multiple resource types
- [ ] Batch processing capabilities
- [ ] Custom field type definitions
- [ ] Resource preview system
- [ ] Template system for quick resource creation
- [ ] Search and filter functionality
- [ ] Resource dependency management
- [ ] Export/Import functionality for different formats

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Developed by [Your Name]

## Support

If you encounter any problems or have suggestions, please open an issue on the GitHub repository.

## Version History

- v1.0.0 (Current)
  - Initial release
  - Basic resource editing functionality
  - Image support
  - Save/Load/Delete operations