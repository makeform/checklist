# @makeform/checklist

“A table-style checklist widget that displays a list of items for users to review. Each item can be either ‘checked’ or ‘rejected’ based on the user’s self-assessment, and the acceptable options are configurable.”


## Configs

 - `items`: a list of string / objects for users to check. For object entries, it contains following fields:
   - `description`: string. the checklist item text. mandatory.
   - `note`: a list of string as the note of this item.
   - `check`: optional. if set, should be either true or false.
     - If not provided, the user’s choice will always be considered correct regardless of selection.
     - Use to decide the correct answer and this widget will be valid only if all items are checked as expected.


Example configuration:

    {   
      isRequired: true,
      config: {
        items: [
          {
            description: "some description, for item1"
            note: [
              "note 1, perhaps some limitation"
              "note 2, perhaps some reminder"
            ]
            check: true
          }
          "some other description, for item 2"
          "yet another description, for item 3"
        ]
      }
    }


## License

MIT
