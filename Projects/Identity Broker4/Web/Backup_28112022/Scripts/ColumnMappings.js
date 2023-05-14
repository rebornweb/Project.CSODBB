function ColumnMappings(configuration) {

    var mappings = new LinkedList();
    
    var leftSideKeys = configuration.leftSideKeys;

    var formatText = configuration.formatText;
    var formatDisplay = configuration.formatDisplay;
    var name = configuration.name;

    // Adds the provided mapping to the mappings.
    this.AddMapping = function (mapping) {
        mappings.Push({ Next: null, Value: mapping });
    };

    // Removes the provided mapping from the mappings.
    this.DeleteMapping = function (index) {
        mappings.RemoveAt(index);
        this.Commit();
    };

    this.GetMapping = function (index) {

        return mappings.Get(index);
        
    };

    // Returns the plain-text column mappings value.
    this.Value = function () {
        var value = '';

        mappings.Visit(
            function (count, component) {

                value += component.left;
                value += "::";
                value += component.right;
                value += "\n";

            }
        );

        return value;
    };

    // Commits the current value to the underlying textarea.
    this.Commit = function () {

        formatText.val(this.Value());
        this.Render();

    };

    // Accepts a text value, replacing the underlying components.
    this.Accept = function (text) {

        mappings.Clear();

        var lines = text.split('\n');

        for (var i = 0; i < lines.length; i++) {

            var line = lines[i];

            if (line != '') {
                var values = line.split('::');
                mappings.Push({ Next: null, Value: { left: values[0], right: values[1]} });
            }
        }

        this.Render();
        return true;
    };

    // Renders the current components in the friendly HTML view.
    this.Render = function () {

        formatDisplay.html('');

        mappings.Visit(

            function (count, mapping) {

                formatDisplay.append(
                    
                    '<div id="mapping_' + count + '">' +

                        leftDropDown(mapping.left, count) +

                        '&nbsp;insert into&nbsp;' +

                        rightTextBox(mapping.right, count) + 
                            
                        '&nbsp;' + 
                            
                        deleteButton(count) + 

                    '</div>'

                );
            }

        );

    };

    var leftDropDown = function (selectedValue, index) {

        var returnValue = '<select onchange="var currentValue = $(\'#mapping_' + index + ' select option:selected\').val(); var mapping = ' + name + '.GetMapping(' + index + '); mapping.Value.left = currentValue; mapping.Value.right = currentValue; ' + name + '.Commit(); ">';

        for (var i = 0; i < leftSideKeys.length; i++) {

            var key = leftSideKeys[i];

            var selectedPlaceholder = '>';
            if (selectedValue == key) {

                selectedPlaceholder = ' selected="selected">';

            }

            returnValue += '<option value="' + key + '"' + selectedPlaceholder + key + "</option>";

        }

        returnValue += '</select>';

        return returnValue;

    };

    var rightTextBox = function (selectedValue, index) {

        return '<input type="text" value="' + selectedValue + '" onchange="var currentValue = $(this).val(); var mapping = ' + name + '.GetMapping(' + index+ '); mapping.Value.right = currentValue; ' + name + '.Commit();"/>';

    };

    var deleteButton = function (index) {

        return '<a href="javascript:;" onclick="' + name + '.DeleteMapping(' + index + ');return false;">Delete</a>';

    };
}