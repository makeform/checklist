# @makeform/checklist

Fields:

 - `items`: a list of string / objects for users to check. For object entries, it contains following fields:
   - `description`: the checklist item text.
   - `note`: a list of string as the note of this item.
   - `check`: optional. if set, should be either true or false. Use to decide the correct answer and this widget will be valid only if all items are checked as expected.


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
