/*
joinMappingStrGenerator PlugIn
copyToMappingStrGenerator PlugIn
searchForMappingWidgetAgent PlugIn
dnStrGenerator PlugIn

jquery prerequirement:    
    <!-- smoothness -->
    <link href="jQueryUI_1.11.2_Smothness/jquery-ui.smoothness.1.11.2.css" rel="stylesheet" />
    <link href="jQueryUI_1.11.2_Smothness/jquery-ui.smoothness.structure.1.11.2.css" rel="stylesheet" />
    <link href="jQueryUI_1.11.2_Smothness/jquery-ui.smoothness.theme.1.11.2.css" rel="stylesheet" />
    <script src="jQueryUI_1.11.2_Smothness/jquery.1.11.1.min.js"></script>
    <script src="jQueryUI_1.11.2_Smothness/jquery-ui.1.11.2.min.js"></script>
    <!-- Helper -->
    <script src="jquery.unify.globalhelpers.js"></script>
    <!-- dnStrGenerator   copyToMappingStrGenerator   joinMappingStrGenerator -->
    <!--<script src="mappingstrfactory/jquery.unify.mappingstrfactory.js"></script>-->
    <script src="mappingstrfactory/jquery.unify.mappingstrfactory.min.js"></script>
    <link href="mappingstrfactory/jquery.unify.mappingstrfactory.css" rel="stylesheet" />              
                    OR

    <link href="http://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css" rel="stylesheet" />
    <script src="http://code.jquery.com/jquery-1.11.0.js"></script>
    <script src="http://code.jquery.com/ui/1.11.0/jquery-ui.js"></script>
*/

(function ($) {
    // ================================================== Begin of    Enum ==================================================
    /// <summary>
    ///     Enum : 
    ///     columnTypeEnum
    ///      Example:
    ///         alert("in helper.js " + columnTypeEnum().columnType.editableDropdown.toString()); 
    /// </summary>
    this.columnTypeEnum = (function () {
        var constValues = constValues || {}     // constValues can be null or {} or something.
        constValues.columnType = {
            // DropDown
            editableDropdown: "editableDropdown",    	// textbox and dropdownBtn , with autocomplete  // _leftColumnType  or  _rightColumnType
            editableDropdownValidValue: "editableDropdownValidValue",		// textbox and dropdownBtn , with autocomplete, but chosen value must from the dropdown menu    // _leftColumnType  or  _rightColumnType
            editableDropdownValidValueCopyToOther: "editableDropdownValidValueCopyToOther",     // textbox and dropdownBtn , with autocomplete, but chosen value must from the dropdown menu.  Once chosen, then copy the value to other column    // _leftColumnType  or  _rightColumnType
            dropdownCopyToOther: "dropdownCopyToOther", // textbox and dropdownBtn , with autocomplete.  Once chosen, then copy the value to other column     // _leftColumnType  or  _rightColumnType
            dropdown: "dropdown",				// normal dropdown      // _leftColumnType  or  _rightColumnType

            // Textbox
            autocompleteTextbox: "autocompleteTextbox",			// textbox, with autocomplete   // _leftColumnType  or  _rightColumnType
            textbox: "textbox",		// normal textbox   // _leftColumnType  or  _rightColumnType

            // SelectDropdown
            selectDropdown: "selectDropdown",

            // Label
            labelDisplay: "labelDisplay",

            // column mapping widget
            copyToMappingComponentSeparatorColumn: "copyToMappingComponentSeparatorColumn", // _componentSeparatorColumnType
            searchForMappingComponentSeparatorColumn: "searchForMappingComponentSeparatorColumn", // _componentSeparatorColumnType
            joinMappingComponentSeparatorColumn: "joinMappingComponentSeparatorColumn", // _componentSeparatorColumnType

            // dnStrGenerator widget
            dnHeaderColumnEditableDropdown: "dnHeaderColumnEditableDropdown",   // _leftColumnType
            dnValueColumnEditableDropdown: "dnValueColumnEditableDropdown", // _rightColumnType
            dnComponentSeparatorColumn: "dnComponentSeparatorColumn",    // _componentSeparatorColumnType

            // sequenceGenerator widget
            sequenceComponentSeparatorColumn: "sequenceComponentSeparatorColumn"    // _componentSeparatorColumnType
        }
        constValues.error = { "ERROR_OUTOFINDEX": "Out of Index" }
        return constValues;
    }); // End of    this.columnTypeEnum = (function () {




    /// <summary>
    ///     Enum : 
    ///     widgetClassNameEnum
    //      Example:
    ///         alert("in helper.js " + widgetClassNameEnum().widgetClassName.joinMappingStrGenerator.toString()); 
    ///         search   widgetClassNameEnum().widgetClassName.joinMappingStrGenerator.toString() 
    /// </summary>
    this.widgetClassNameEnum = (function () {
        var constValues = constValues || {}     // constValues can be null or {} or something.
        constValues.widgetClassName = {
            // the jquery plugin name
            joinMappingStrGenerator: "joinMappingStrGenerator",
            copyToMappingStrGenerator: "copyToMappingStrGenerator",
            searchForMappingStrGenerator: "searchForMappingStrGenerator",
            dnStrGenerator: "dnStrGenerator",
            directionMappingStrGenerator: "directionMappingStrGenerator"
        }
        constValues.error = { "ERROR_OUTOFINDEX": "Out of Index" }
        return constValues;
    }); // End of    this.widgetClassNameEnum = (function () {
    // ================================================== End of    Enum ==================================================





    // ================================================== Begin of    mappingStrFactory ==================================================
    /// <summary>
    ///     Class : 
    ///     mappingStrFactory
    /// </summary>
    var mappingStrFactory = function (elementID, mappingStr, isAlwaysShownColumnMappingStrFieldDisplay, sortableWidgetWidth, leftColumnHeaderLabelStrDisplay, leftAndRightSeparatorHeaderLabelStrDisplay, rightColumnHeaderLabelStrDisplay, componentSeparatorHeaderLabelStrDisplay, isShowedLeftColumnHeaderLabelStrDisplay, isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, isShowedRightColumnHeaderLabelStrDisplay, isShowedComponentSeparatorHeaderLabelStrDisplay, componentSeparatorStyle, leftColumnDataArr, rightColumnDataArr, lastComponentSeparatorDefaultValue, isShowedComponentSeparator, componentSeparatorDataArr, componentSeparatorStrDisplay, isShowedleftAndRightSeparator, leftAndRightSeparatorType, leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, leftAndRightSeparatorStrDisplay, leftAndRightSeparatorStrReal, leftAndRightSeparatorIndexOfSelectDefaultValue, leftAndRightSeparatorSelectValuesRealArr, leftAndRightSeparatorselectValuesDisplayArr, leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, escapedSymbolsArr, dragBtnTipStr, isShowedRemoveBtn, removeBtnTipStr, editBtnTipStr, isShowedLeftColumnTextboxDisplay, isShowedLeftColumnTextbox, leftColumnType, isShowedRightColumnTextboxDisplay, isShowedRightColumnTextbox, rightColumnType, componentSeparatorColumnType, beforeEdit, afterEdit, isShowedAddBtn, addBtnTipStr, beforeAddComponent, afterAddComponent, isShowedCommitBtn, commitBtnTipStr, beforeCommit, afterCommit, isShowedClearBtn, clearBtnTipStr, beforeClearComponent, afterClearComponent, isShowedCancelBtn, cancelBtnTipStr, beforeCancel, afterCancel) {       ////// adding more parameter here

        // -------------------------------------- Begin of     Global variable --------------------------------------
        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element ~~~~~~~~~~~~~~~~~~~~~
        this._elementID = ""; // E.g. #dnStrGenerator   or    #copyToMappingStrGenerator
        var _element = null; // Get the element  //_element = $("#dnStrGenerator");     or     _element = $("#copyToMappingStrGenerator"); 

        // sortable widget HTML code
        var _htmlCodeStr = '<div class="ColumnMappingComboBox"> <div class="ColumnMappingStrField toNextLine"> <div class="toNextLine" style="display: none;"> Display DN String : </div><div class="ColumnMappingStrFieldDisplay toNextLine"> DC=[kevin]+Bob=Kevin,Bob@unify<span style="color: blue; font-size: 20px; font-weight: bold;">&nbsp;+&nbsp;</span> CN=Chris21 <span style="color: blue; font-size: 20px; font-weight: bold;">&nbsp;+&nbsp;</span> Protocol=LDAP </div><div class="toNextLine" style="display: none;"> Real DN String : </div><div class="ColumnMappingStrFieldReal toNextLine" style="display: none;"> DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21+Protocol=LDAP </div><div class="ColumnMappingEditBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Edit </div></div><div class="ColumnMappingHeaderLabel toNextLine"> <span class="LeftColumnHeaderLabel LeftColumnHeaderLabelStyle"></span> <span class="LeftAndRightSeparatorHeaderLabel LeftAndRightSeparatorHeaderLabelStyle"></span> <span class="RightColumnHeaderLabel RightColumnHeaderLabelStyle"></span> <span class="ComponentSeparatorHeaderLabel ComponentSeparatorHeaderLabelStyle"></span> </div><div class="ColumnMappingWidget toNextLine"> <div class="SortableWidgetTemplate" style="height: 0px; visibility: hidden; width: 0px;"> <div class="SortableWidgetItem SortableWidgetItemStyle ui-state-default" style="width: auto;"> <span class="SortableWidgetItemDragBtnPlaceHolder SortableWidgetItemComponentStyle DragBtnStyle"> <span class="SortableWidgetItemDragBtn ui-icon ui-icon-arrowthick-2-n-s"></span> </span> <span class="LeftColumnTextboxPlaceHolder SortableWidgetItemComponentStyle"> <span><span class="LeftColumnTextboxDisplay TextboxDisplayStyle"></span></span> <span><input class="LeftColumnTextbox TextboxStyle"/></span> <span> <a class="LeftColumnDropdownBtn DropdownBtnStyle" href="javascript:;"> <span class="ui-icon ui-icon-triangle-1-s DropdownBtnPicStyle"></span> </a> </span> </span> <span class="LeftAndRightSeparatorPlaceHolder SortableWidgetItemComponentStyle"> <span class="LeftAndRightSeparatorDisplay LeftAndRightSeparatorDisplayStyle"></span> <span class="LeftAndRightSeparatorReal" style="display: none;"></span> <select class="LeftAndRightSeparatorSelectValuesDisplay LeftAndRightSeparatorSelectValuesDisplayStyle" style="display: none;"></select> </span> <span class="RightColumnTextboxPlaceHolder SortableWidgetItemComponentStyle"> <span><span class="RightColumnTextboxDisplay TextboxDisplayStyle"></span></span> <span> <input class="RightColumnTextbox TextboxStyle"/> </span> <span> <a class="RightColumnDropdownBtn DropdownBtnStyle" href="javascript:;"> <span class="ui-icon ui-icon-triangle-1-s DropdownBtnPicStyle"></span> </a> </span> </span> <span class="ComponentSeparatorPlaceHolder SortableWidgetItemComponentStyle"> <select class="ComponentSeparator"></select> <span class="ComponentSeparatorDisplay" style="display: none;"></span> </span> <span class="ComponentRemoveBtnPlaceHolder ComponentRemoveBtnPlaceHolderStyle SortableWidgetItemComponentStyle"> <span class="ComponentRemoveBtn ComponentRemoveBtnStyle ui-icon ui-icon-closethick"></span> </span> </div></div><div class="SortableWidgetPlaceHolder toNextLine"> <div class="SortableWidget SortableWidgetStyle"> </div></div><div class="SortableWidgetBtnsPlaceHolder toNextLine"> <div class="SortableWidgetAddBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Add </div><div class="SortableWidgetCommitBtn WidgetBtnStyle WidgetBtnTextStyle m-btn green"> Commit </div><div class="SortableWidgetClearBtn WidgetBtnStyle WidgetBtnTextStyle m-btn red"> Clear </div><div class="SortableWidgetCancelBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Cancel </div></div></div></div>';

        // .ColumnMappingStrField   // the place holder for the dn result string real and display element 
        var _columnMappingStrFieldElement = null; //_element.find(".ColumnMappingStrField");
        var _columnMappingStrFieldDisplayElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingStrFieldDisplay");
        var _columnMappingStrFieldRealElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingStrFieldReal");
        var _columnMappingEditBtnElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingEditBtn");

        // .ColumnMappingWidgetLabel element
        var _columnMappingHeaderLabelElement = null;        // _element.find(".ColumnMappingHeaderLabel");
        var _leftColumnHeaderLabelElement = null;        // _columnMappingHeaderLabelElement.find(".LeftColumnHeaderLabel");
        var _leftAndRightSeparatorHeaderLabelElement = null;        // _columnMappingHeaderLabelElement.find(".LeftAndRightSeparatorHeaderLabel");
        var _rightColumnHeaderLabelElement = null;        // _columnMappingHeaderLabelElement.find(".RightColumnHeaderLabel");
        var _componentSeparatorHeaderLabelElement = null;        // _columnMappingHeaderLabelElement.find(".ComponentSeparatorHeaderLabel");
        // HeaderLabelElement value
        var _leftColumnHeaderLabelStrDisplay = "";    // str    // inputLeftColumnHeaderLabelStrDisplay;
        var _leftAndRightSeparatorHeaderLabelStrDisplay = "";    // str    // inputLeftAndRightSeparatorHeaderLabelStrDisplay;
        var _rightColumnHeaderLabelStrDisplay = "";    // str    // inputRightColumnHeaderLabelStrDisplay;
        var _componentSeparatorHeaderLabelStrDisplay = "";    // str    // inputComponentSeparatorHeaderLabelStrDisplay;
        // IsShowedHeaderLabelElement value
        var _isShowedLeftColumnHeaderLabelStrDisplay = false;   // inputIsShowedLeftColumnHeaderLabelStrDisplay;
        var _isShowedLeftAndRightSeparatorHeaderLabelStrDisplay = false;   // inputIsShowedLeftAndRightSeparatorHeaderLabelStrDisplay;
        var _isShowedRightColumnHeaderLabelStrDisplay = false;   // inputIsShowedRightColumnHeaderLabelStrDisplay;
        var _isShowedComponentSeparatorHeaderLabelStrDisplay = false;   // inputIsShowedComponentSeparatorHeaderLabelStrDisplay;

        // .ColumnMappingWidget element  // the component template to clone  
        var _columnMappingWidgetElement = null; //_element.find(".ColumnMappingWidget");       
        // .SortableWidgetItem element
        var _sortableWidgetItemElement = null; // _columnMappingWidgetElement.find(".SortableWidgetTemplate").find(".SortableWidgetItem")    
        var _leftAndRightSeparatorDisplayElement = null;
        var _leftAndRightSeparatorRealElement = null;
        var _leftAndRightSeparatorSelectValuesDisplayElement = null;
        var _componentSeparatorDisplayElement = null;

        // .SortableWidget element  // the cloned component object place holder
        var _sortableWidgetElement = null;    //_columnMappingWidgetElement.find(".SortableWidgetPlaceHolder").find(".SortableWidget")
        var _sortableWidgetWidth = "";     // E.g. "581px"

        // .SortableWidgetBtnsPlaceHolder element   // the btns place holder
        var _sortableWidgetBtnsPlaceHolderElement = null;    // _columnMappingWidgetElement.find(".SortableWidgetBtnsPlaceHolder")    
        var _sortableWidgetAddBtnElement = null;   // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetAddBtn")         
        var _sortableWidgetCommitBtnElement = null; // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCommitBtn")         
        var _sortableWidgetClearBtnElement = null; // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetClearBtn")  
        var _sortableWidgetCancelBtnElement = null; //_sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCancelBtn");
        // ~~~~~~~~~~~~~~~~~~~~~ End of   Element ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~
        // tool tip string
        var _dragBtnTipStr = ""; // Drage Btn tip
        var _removeBtnTipStr = ""; // Close or remove btn tip
        var _editBtnTipStr = ""; // Edit btn tip
        var _addBtnTipStr = ""; // Add btn tip
        var _commitBtnTipStr = ""; // Commit btn tip
        var _clearBtnTipStr = ""; // Clear btn tip
        var _cancelBtnTipStr = ""; // Cancel btn tip
        // ~~~~~~~~~~~~~~~~~~~~~ End of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~
        // CallBack Event
        var emptyFunction = function () { };
        var _beforeEdit = emptyFunction;
        var _afterEdit = emptyFunction;
        var _beforeAddComponent = emptyFunction;
        var _afterAddComponent = emptyFunction;
        var _beforeCommit = emptyFunction;
        var _afterCommit = emptyFunction;
        var _beforeClearComponent = emptyFunction;
        var _afterClearComponent = emptyFunction;
        var _beforeCancel = emptyFunction;
        var _afterCancel = emptyFunction;
        // ~~~~~~~~~~~~~~~~~~~~~ End of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~
        var _isShowedComponentSeparator = false;    //inputIsShowedComponentSeparator;  //  is Showed ComponentSeparator
        var _isShowedleftAndRightSeparator = false;    //inputIsShowedleftAndRightSeparator;    //  is Showed leftAndRightSeparator
        var _isShowedRemoveBtn = false;    //inputIsShowedRemoveBtn;    //  is Showed RemoveBtn
        var _isShowedLeftColumnTextboxDisplay = false;    //inputIsShowedLeftColumnTextboxDisplay;  //  is Showed LeftColumnTextboxDisplay
        var _isShowedLeftColumnTextbox = false;    //inputIsShowedLeftColumnTextbox;    //  is Showed LeftColumnTextbox
        var _isShowedRightColumnTextboxDisplay = false;    //inputIsShowedRightColumnTextboxDisplay;    //  is Showed RightColumnTextboxDisplay
        var _isShowedRightColumnTextbox = false;    //inputIsShowedRightColumnTextbox;  //  is Showed RightColumnTextbox
        var _isShowedAddBtn = false;    //inputIsShowedAddBtn;  //  is Showed AddBtn
        var _isShowedCommitBtn = false;    //inputIsShowedCommitBtn;    //  is Showed CommitBtn
        var _isShowedClearBtn = false;    //inputIsShowedClearBtn;  //  is Showed ClearBtn
        var _isShowedCancelBtn = false;    //inputIsShowedCancelBtn;    //  is Showed CancelBtn
        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   value setting ~~~~~~~~~~~~~~~~~~~~~
        var _mappingStr = "";    // initial mapping String 
        var _escapedSymbolsArr = null; // Escaped symbols array.  All the symbol which should add escape in right column Textbox    // E.g. _escapedSymbolsArr = ["+", "=", ",", "[", "]", "@"];
        // ColumnType
        var _leftColumnType = "";    // string  // E.g. columnType.dnHeaderColumnEditableDropdown.toString(),
        var _rightColumnType = "";   // string  //E.g. columnType.dnValueColumnEditableDropdown.toString(),
        var _componentSeparatorColumnType = "";  // stgring // E.g. columnType.dnComponentSeparatorColumn.toString(),
        // ~~~~~~~~~~~~~~~~~~~~~ End of   value setting ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   column attribute setting ~~~~~~~~~~~~~~~~~~~~~
        // .ColumnMappingStrField attribute   // the place holder for the dn result string real and display element 
        _isAlwaysShownColumnMappingStrFieldDisplay = false;       // show or hide the _columnMappingStrFieldDisplayElement which class=".ColumnMappingStrFieldDisplay".

        // leftColumn attribute
        var _leftColumnAttributes = {
            enableAutoComplete: true, // bool // is the column autocomplete on or off?
            isShownDropdownBtn: true, // bool // is the dropdown btn show or not?
            isTextboxReadOnly: false, // bool, // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
            isValuseMustValid: false, // bool // is the value of this column must in the array? false means the value must be one of item in that array.
            isValuseMustValidTooltipDuration: 2000, // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
            isValuseMustValidTooltipMessage: " is not a valid value.", // string //the message for tooltip if (isValuseMustValid)
            enableEscapedSymbol: true,                      // bool // true, then textbox will add "\" to string in this column
            enableEscapedSymbolButNoEscapedForField: true,  // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
            enableCheckIfFieldAndHideOtherColumns: true,    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
            enableCopyValueToNeighbour: false // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
        };
        var _leftColumnDataArr = null; // E.g. _leftColumnDataArr = ["DC", "CN", "OU", "O", "STREET", "L", "ST", "C", "UID", "[FieldC]", "@FieldD"];

        // leftAndRightSeparator attribute
        var _leftAndRightSeparatorAttributes = {
            leftAndRightSeparatorType: "",
            strDisplayInColumnMappingStrFieldDisplay: "", // string     // the display string of left column and right column separator in ColumnMappingStrField which class=".ColumnMappingStrField".
            strDisplay: "", // string   // the display string in LeftAndRightSeparatorDisplay (class="LeftAndRightSeparatorDisplay") of left column and right column separator
            strReal: "", // string
            indexOfSelectDefaultValue: 0,
            selectValuesDisplayArr: [],
            selectValuesRealArr: [],
            selectValuesDisplayArrInColumnMappingStrFieldDisplay: []    // The display string values in dropdown menu of left column and right column separator in ColumnMappingStrFieldDisplay which class=".ColumnMappingStrFieldDisplay"
        };

        // rightColumn attribute
        var _rightColumnAttributes = {
            enableAutoComplete: true, // bool // is the column autocomplete on or off?
            isShownDropdownBtn: true, // bool // is the dropdown btn show or not?
            isTextboxReadOnly: false, // bool, // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
            isValuseMustValid: false, // bool // is the value of this column must in the array? false means the value must be one of item in that array.
            isValuseMustValidTooltipDuration: 2000, // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
            isValuseMustValidTooltipMessage: " is not a valid value.", // string //the message for tooltip if (isValuseMustValid)
            enableEscapedSymbol: true,                      // bool // true, then textbox will add "\" to string in this column
            enableEscapedSymbolButNoEscapedForField: true,  // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
            // enableCheckIfFieldAndHideOtherColumns: true,    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
            enableCopyValueToNeighbour: false // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
        };
        var _rightColumnDataArr = null; // E.g. _rightColumnDataArr = ["Bob", "Unify", "Chris21", "Smith", "Kevin"];

        // componentSeparatorColumn attribute
        var _componentSeparatorColumnAttributes = {
            isHideButStillSerialise: false,      // bool // is component separator hide, and it is still serialised included.
            displayStr: ""                     // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
        };
        var _lastComponentSeparatorDefaultValue = ""; // Last component separator default value  E.g.  _lastComponentSeparatorDefaultValue = ",";
        var _componentSeparatorDataArr = null; // Component separator data array.  E.g. _componentSeparatorDataArr = [",", "+"];</param>
        var _componentSeparatorStyle = null;  // add style to component separator  E.g. "," , "+"   // var _componentSeparatorStyle = { "font-weight": "bold", "color": "blue", "font-size": "20px" }
        // ~~~~~~~~~~~~~~~~~~~~~ End of   column attribute setting ~~~~~~~~~~~~~~~~~~~~~
        // -------------------------------------- End of     Global variable --------------------------------------




        // -------------------------------------- Begin of     Helper --------------------------------------
        /// <summary>
        ///     Add tipMessage to target element
        /// </summary>
        /// <param name="targetElement">Target element.</param>
        /// <param name="tipMessage"Ttip message string.</param>
        var addTooltip = function (targetElement, tipMessageStr) {
            var jQueryUiToolTipHelperObj = (new jQueryUiToolTipHelper()).addToolTip(targetElement, tipMessageStr);
        }; // End of   function addTooltip(targetElement, tipMessage)    // End of   var addTooltip = function (targetElement, tipMessage)


        /// <summary>
        ///     Set IsField and set result string with escaped symbol.
        ///     1. Field rule:
        ///         1.1. When @ is if the first char of the string, that means the string is field name (set isField=true)
        ///         1.2. When "[" is in the first char of string, and "]" is the last char itar the string, that means the string is field name (set isField=true)
        ///         1.3. if(isField===true), then do not add escapte symbol "\" in front of symbol from inputEscapedSymbolArr.
        ///         1.4. if(isField===true) and if(inputStr) come from DNHeader (LeftColumn), then hide the DNValue (RightClumn).
        ///     2.
        ///         2.1.
        ///         if(enableEscapedSymbolButNoEscapedForField==true) then 
        ///             determine isField===ture or false,   
        ///             add escapte symbol "\" in front of the symbols in _inputEscapedSymbolsArr except if(isField===true)
        ///         2.2.
        ///         if(enableEscapedSymbolButNoEscapedForField==false) then  
        ///             add escapte symbol "\" in front of the symbols in _inputEscapedSymbolsArr 
        /// </summary>
        /// <param name="inputString">input string, normally it is Distinguished Name string. DNString.</param>
        /// <param name="enableEscapedSymbolButNoEscapedForField">bool.  if true, then add escaped symbol "\"  except if(isField===true).</param>
        /// <returns>the result string which has add escaped symbol"\" .</returns>
        var replaceWithEscapedSymbol = function (inputStr, enableEscapedSymbolButNoEscapedForField) {
            return (enableEscapedSymbolButNoEscapedForField) ?
                ((new strSpecialRuleHelper()).setIsFieldAndSetResultStrWithEscapedSymbol(inputStr, _escapedSymbolsArr))._resultStr :
                ((new strSpecialRuleHelper()).setResultStrWithEscapedSymbol(inputStr, _escapedSymbolsArr))._resultStr;
        }; // End of     function replaceWithEscapedSymbol(inputStr) // End of   var replaceWithEscapedSymbol = function (inputStr)


        /// <summary>
        ///     Convert string to ComponentArr.
        ///     1. parameter: inputMappingStr
        ///         E.g.    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP
        ///     2. set _mappingStrToComponentArr
        ///         _mappingStrToComponentArr === [componentArr, componentSeparatorArr, componentArr.length]  // a 3d array
        ///         E.g.    _mappingStrToComponentArr[0] === componentArr === { "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  , "CN=Chris21"  ,  "Protocol=LDAP" }
        ///                 _mappingStrToComponentArr[1] === componentSeparatorArr === { ","  ,  ","  ,   ","} ===  { ","  ,  ","  ,  , inputLastComponentSeparatorDefaultValue } 
        ///                 _mappingStrToComponentArr[2] === componentArr.length === 3
        /// </summary>
        /// <param name="inputMappingStr">input mapping string.   E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP</param>
        /// <returns> _mappingStrToComponentArr === [componentArr, componentSeparatorArr, componentArr.length]  </returns>
        var convertMappingStrToComponentArr = function (inputMappingStr) {
            return (new mappingStrConverterForSerializationHelper()).setMappingStrToComponentArr(inputMappingStr, _componentSeparatorDataArr, _lastComponentSeparatorDefaultValue)._mappingStrToComponentArr;
        }; // End of  convertMappingStrToComponentArr(inputMappingStr)  // End of   var convertMappingStrToComponentArr = function (inputMappingStr)


        /// <summary>
        ///     Convert component string to leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal and rightColumnStrWithoutEscapte.
        ///     1. parameter: 
        ///         1.1. inputComponentStr : input component string
        ///         E.g.    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify
        ///         1.2. leftAndRightSeparatorStr : left and right separator string.
        ///         E.g.    '='
        ///     2. Return:
        ///         [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte]
        ///         E.g.    [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify' ]
        /// </summary>
        /// <param name="inputComponentStr">input component string.  E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify</param>
        /// <returns>[leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte].    E.g. [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify' ] </returns>
        var convertComponentStrToLeftColumnAndRightColumnArrWithoutEscaped = function (inputComponentStr, leftAndRightSeparatorStr) {
            return ((new mappingStrConverterForSerializationHelper()).setLeftColumnAndRightColumnArrFromComponentStrWithoutEscapedStr(inputComponentStr, leftAndRightSeparatorStr))._leftColumnAndRightColumnArrWithoutEscapedStr;
        }; // End of  convertComponentStrToLeftColumnAndRightColumnArrWithoutEscaped(inputComponentStr)    // End of   function convertComponentStrToLeftColumnAndRightColumnArrWithoutEscaped(inputComponentStr)


        /// <summary>
        ///     Convert component string to leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte and leftAndRightSeparatorStrInColumnMappingStrFieldDisplay.
        ///     1. parameter: 
        ///         1.1. inputComponentStr : input component string
        ///         E.g.    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify
        ///     2. Return:
        ///         [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte, leftAndRightSeparatorStrInColumnMappingStrFieldDisplay]
        ///         E.g.    [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify', '<span style="color: blue;font-weight:bold;font-size:20px">=</span>' ]
        /// </summary>
        /// <param name="inputComponentStr">input component string.  E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify</param>
        /// <returns>[leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte, leftAndRightSeparatorStrInColumnMappingStrFieldDisplay].    E.g. [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify' , '<span style="color: blue;font-weight:bold;font-size:20px">=</span>' ] </returns>
        var toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay = function (inputComponentStr) {
            var leftAndRightSeparatorStrInColumnMappingStrFieldDisplay = "";    // str  // the left and right separator display string in ColumnMappingStrFieldDisplay which class="ColumnMappingStrFieldDisplay"
            var leftColumnAndRightColumnArr;
            if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) {
                for (var j = 0; j < _leftAndRightSeparatorAttributes.selectValuesRealArr.length; j++) {
                    if ((new strSpecialRuleHelper()).containSubStr(inputComponentStr, _leftAndRightSeparatorAttributes.selectValuesRealArr[j], true)._isContainElement) {
                        // leftColumnAndRightColumnArr = [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte]
                        leftColumnAndRightColumnArr = convertComponentStrToLeftColumnAndRightColumnArrWithoutEscaped(inputComponentStr, _leftAndRightSeparatorAttributes.selectValuesRealArr[j]);
                        leftAndRightSeparatorStrInColumnMappingStrFieldDisplay = "<span>" + _leftAndRightSeparatorAttributes.selectValuesDisplayArr[j] + "</span>";
                        if (_leftAndRightSeparatorAttributes.selectValuesDisplayArrInColumnMappingStrFieldDisplay[j] !== "" || _leftAndRightSeparatorAttributes.selectValuesDisplayArrInColumnMappingStrFieldDisplay[j] !== null) {
                            leftAndRightSeparatorStrInColumnMappingStrFieldDisplay = _leftAndRightSeparatorAttributes.selectValuesDisplayArrInColumnMappingStrFieldDisplay[j]
                        }
                        break;
                    }
                }
            } else {
                // if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.labelDisplay.toString())
                // leftColumnAndRightColumnArr = [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte]
                leftColumnAndRightColumnArr = convertComponentStrToLeftColumnAndRightColumnArrWithoutEscaped(inputComponentStr, _leftAndRightSeparatorAttributes.strReal);
                leftAndRightSeparatorStrInColumnMappingStrFieldDisplay = _leftAndRightSeparatorAttributes.strDisplayInColumnMappingStrFieldDisplay;
            }
            // return [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte, leftAndRightSeparatorStrInColumnMappingStrFieldDisplay];
            return [leftColumnAndRightColumnArr[0], leftColumnAndRightColumnArr[1], leftColumnAndRightColumnArr[2], leftAndRightSeparatorStrInColumnMappingStrFieldDisplay];
        }; // End of  toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay(inputComponentStr, leftAndRightSeparatorStr)


        /// <summary>
        ///     if LeftColumn isField === ture, and 
        ///         if leftAndRightSeparatorType === selectDropdown
        ///             Hide selectDropdownHideOrShowTargetElementsArr
        ///         if leftAndRightSeparatorType === labelDisplay
        ///             Hide labelDisplayHideOrShowTargetElementsArr
        /// </summary>
        /// <param name="isFieldLeftColumnStr">Whether the left column isField or not.   E.g. isField means '@XXXX' or '[XXXXX]' , but not includes '\@XXX' and '\[XXXXX\]' </param>
        /// <param name="selectDropdownHideOrShowTargetElementsArr">The target elements which will be hidden if(LeftColumn isField === ture) and if(leftAndRightSeparatorType === selectDropdown)     E.g. [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorSelectValuesDisplayElement]</param>
        /// <param name="labelDisplayHideOrShowTargetElementsArr">The target elements which will be hidden if(LeftColumn isField === ture) and if(leftAndRightSeparatorType === labelDisplay)  E.g. [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement]</param>
        var ifLeftColumnIsFieldAndHideOtherColumns = function (isFieldLeftColumnStr, selectDropdownHideOrShowTargetElementsArr, labelDisplayHideOrShowTargetElementsArr) {
            if (_leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns) {
                if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) {
                    // hideORshowTheTargetElements(isFieldLeftColumnStr, [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorSelectValuesDisplayElement]); // hideORshowTheTargetElements(isHide, targetElementArr)
                    hideORshowTheTargetElements(isFieldLeftColumnStr, selectDropdownHideOrShowTargetElementsArr); // hideORshowTheTargetElements(isHide, targetElementArr)
                } else {
                    // hideORshowTheTargetElements(isFieldLeftColumnStr, [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement]); // hideORshowTheTargetElements(isHide, targetElementArr)
                    hideORshowTheTargetElements(isFieldLeftColumnStr, labelDisplayHideOrShowTargetElementsArr); // hideORshowTheTargetElements(isHide, targetElementArr)
                }
            }
        }; // End of  ifLeftColumnIsFieldAndHideOtherColumns(isFieldLeftColumnStr, selectDropdownHideOrShowTargetElementsArr, labelDisplayHideOrShowTargetElementsArr)
        // -------------------------------------- End of     Helper --------------------------------------




        // -------------------------------------- Begin of     Constructor --------------------------------------
        /// <summary>
        ///     Constructor : 
        ///     Select the elements and set the default data.
        /// </summary>
        /// <param name="inputElementID">the element id.  E.g.  #dnStrGenerator   or    #copyToMappingStrGenerator, then   _element = $("#dnStrGenerator");   or   _element = $("#copyToMappingStrGenerator");</param>
        /// <param name="inputMappingStr">The initial mapping string.</param>
        /// <param name="inputIsAlwaysShownColumnMappingStrFieldDisplay">Show or hide the _columnMappingStrFieldDisplayElement which class=".ColumnMappingStrFieldDisplay".</param>
        /// <param name="inputSortableWidgetWidth">The initial sortable widget width.</param>
        /// <param name="inputLeftColumnHeaderLabelStrDisplay">The display header string on the top of left column.</param>
        /// <param name="inputLeftAndRightSeparatorHeaderLabelStrDisplay">The display header string on the top of leftAndRightSeparator column.</param>
        /// <param name="inputRightColumnHeaderLabelStrDisplay">The display header string on the top of right column.</param>
        /// <param name="inputComponentSeparatorHeaderLabelStrDisplay">The display header string on the top of ComponentSeparator column.</param>
        /// <param name="inputIsShowedLeftColumnHeaderLabelStrDisplay">Whether to show the display header string on the top of left column..</param>
        /// <param name="inputIsShowedLeftAndRightSeparatorHeaderLabelStrDisplay">Whether to show the display header string on the top of leftAndRightSeparator column.</param>
        /// <param name="inputIsShowedRightColumnHeaderLabelStrDisplay">Whether to show the display header string on the top of right column.</param>
        /// <param name="inputIsShowedComponentSeparatorHeaderLabelStrDisplay">Whether to show the display header string on the top of ComponentSeparator column.</param>
        /// <param name="inputComponentSeparatorStyle">The component separator style.   E.g. the style of "," , "+" </param>
        /// <param name="inputLeftColumnDataArr">Left column data array.  E.g. _leftColumnDataArr = ["DC", "CN", "OU", "O", "STREET", "L", "ST", "C", "UID", "[FieldC]", "@FieldD"];</param>
        /// <param name="inputRightColumnDataArr">Right column Data Array.  E.g. _rightColumnDataArr = ["Bob", "Unify", "Chris21", "Smith", "Kevin"];</param>
        /// <param name="inputLastComponentSeparatorDefaultValue">Last component separator default value  E.g.  _lastComponentSeparatorDefaultValue = ",";</param>
        /// <param name="inputIsShowedComponentSeparator">Whether to show the component separator.</param>
        /// <param name="inputComponentSeparatorDataArr">Component separator data array.  E.g. _componentSeparatorDataArr = [",", "+"];</param>
        /// <param name="inputComponentSeparatorStrDisplay">if (inputComponentSeparatorStrDisplay !== "") then display the componentSeparatorStrDisplay and hide the real value.  </param>
        /// <param name="inputIsShowedleftAndRightSeparator">Whether to show the left and right separator.</param>
        /// <param name="inputLeftAndRightSeparatorType">The type of the left and right separator. E.g. Lable, SelectDropdown, ...etc.</param>
        /// <param name="inputLeftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay">the display string in the ColumnMappingStrFieldDisplay (class="ColumnMappingStrFieldDisplay") of left column and right column separator</param>
        /// <param name="inputLeftAndRightSeparatorStrDisplay">the display string in LeftAndRightSeparatorDisplay (class="LeftAndRightSeparatorDisplay") of left column and right column separator</param>
        /// <param name="inputLeftAndRightSeparatorStrReal">the actual string of left column and right column separator</param>
        /// <param name="inputLeftAndRightSeparatorIndexOfSelectDefaultValue">The default index of the string values or display string values of the left column and right column separator.</param>
        /// <param name="inputLeftAndRightSeparatorSelectValuesRealArr">The actual string values in dropdown menu of left column and right column separator.</param>
        /// <param name="inputLeftAndRightSeparatorselectValuesDisplayArr">The display string values in dropdown menu of left column and right column separator.</param>
        /// <param name="inputLeftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay">The display string values in dropdown menu of left column and right column separator in ColumnMappingStrFieldDisplay which class=".ColumnMappingStrFieldDisplay".</param>
        /// <param name="inputEscapedSymbolsArr">Escaped symbols array.  All the symbol which should add escape in right column Textbox    // E.g. _escapedSymbolsArr = ["+", "=", ",", "[", "]", "@"];</param>
        /// <param name="inputDragBtnTipStr">the drag btn tip string</param>
        /// <param name="inputIsShowedRemoveBtn">Whether to show the remove separator.</param>
        /// <param name="inputRemoveBtnTipStr">the remove btn tip string</param>
        /// <param name="inputEditBtnTipStr">the edit btn tip string</param>
        /// <param name="inputIsShowedLeftColumnTextboxDisplay">Whether to show the LeftColumnTextboxDisplay separator.</param>
        /// <param name="inputIsShowedLeftColumnTextbox">Whether to show the Left Column.</param>
        /// <param name="inputLeftColumnType">the left column type</param>
        /// <param name="isShowedRightColumnTextboxDisplay">Whether to show the RightColumnTextboxDisplay separator.</param>
        /// <param name="inputIsShowedRightColumnTextbox">Whether to show the Right Column.</param>
        /// <param name="inputRightColumnType">the right column type</param>
        /// <param name="inputComponentSeparatorColumnType">the component separator column type.</param>
        /// <param name="beforeEdit">the function which will run before Edit</param>
        /// <param name="afterEdit">the function which will run after Edit</param>
        /// <param name="inputIsShowedAddBtn">the add btn tip string</param>
        /// <param name="inputAddBtnTipStr">Whether to show the Add Button.</param>
        /// <param name="beforeAddComponent">the function which will run before Add</param>
        /// <param name="afterAddComponent">the function which will run after Add</param>
        /// <param name="inputIsShowedCommitBtn">Whether to show the Commit Button.</param>
        /// <param name="inputCommitBtnTipStr">the commit btn tip string</param>
        /// <param name="beforeCommit">the function which will run before Commit</param>
        /// <param name="afterCommit">the function which will run after Commit</param>
        /// <param name="inputIsShowedClearBtn">Whether to show the Clear Button.</param>
        /// <param name="inputClearBtnTipStr">the clear btn tip string</param>
        /// <param name="beforeClearComponent">the function which will run before Clear</param>
        /// <param name="afterClearComponent">the function which will run after Clear</param>
        /// <param name="inputIsShowedCancelBtn">Whether to show the Cancel Button.</param>
        /// <param name="inputCancelBtnTipStr">the cancel btn tip string</param>
        /// <param name="beforeCancel">the function which will run before Cancel</param>
        /// <param name="afterCancel">the function which will run after Cancel</param>
        /// <returns>this object</returns>
        this.construct = function (inputElementID, inputMappingStr, inputIsAlwaysShownColumnMappingStrFieldDisplay, inputSortableWidgetWidth, inputLeftColumnHeaderLabelStrDisplay, inputLeftAndRightSeparatorHeaderLabelStrDisplay, inputRightColumnHeaderLabelStrDisplay, inputComponentSeparatorHeaderLabelStrDisplay, inputIsShowedLeftColumnHeaderLabelStrDisplay, inputIsShowedLeftAndRightSeparatorHeaderLabelStrDisplay, inputIsShowedRightColumnHeaderLabelStrDisplay, inputIsShowedComponentSeparatorHeaderLabelStrDisplay, inputComponentSeparatorStyle, inputLeftColumnDataArr, inputRightColumnDataArr, inputLastComponentSeparatorDefaultValue, inputIsShowedComponentSeparator, inputComponentSeparatorDataArr, inputComponentSeparatorStrDisplay, inputIsShowedleftAndRightSeparator, inputLeftAndRightSeparatorType, inputLeftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, inputLeftAndRightSeparatorStrDisplay, inputLeftAndRightSeparatorStrReal, inputLeftAndRightSeparatorIndexOfSelectDefaultValue, inputLeftAndRightSeparatorSelectValuesRealArr, inputLeftAndRightSeparatorselectValuesDisplayArr, inputLeftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, inputEscapedSymbolsArr, inputDragBtnTipStr, inputIsShowedRemoveBtn, inputRemoveBtnTipStr, inputEditBtnTipStr, inputIsShowedLeftColumnTextboxDisplay, inputIsShowedLeftColumnTextbox, inputLeftColumnType, inputIsShowedRightColumnTextboxDisplay, inputIsShowedRightColumnTextbox, inputRightColumnType, inputComponentSeparatorColumnType, beforeEdit, afterEdit, inputIsShowedAddBtn, inputAddBtnTipStr, beforeAddComponent, afterAddComponent, inputIsShowedCommitBtn, inputCommitBtnTipStr, beforeCommit, afterCommit, inputIsShowedClearBtn, inputClearBtnTipStr, beforeClearComponent, afterClearComponent, inputIsShowedCancelBtn, inputCancelBtnTipStr, beforeCancel, afterCancel) {      ////// adding more parameter here
            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element ~~~~~~~~~~~~~~~~~~~~~
            // this element
            this._elementID = "#" + inputElementID; // E.g. #dnStrGenerator   or    #copyToMappingStrGenerator
            _element = $(this._elementID); // Get the element  //_element = $("#dnStrGenerator");     or     _element = $("#copyToMappingStrGenerator"); 
            // add class for style
            _element.addClass("ColumnMappingComboBoxStyle");     // Add class="ColumnMappingComboBoxStyle" to <div id="ColumnMappingComboBox"> // <div id="ColumnMappingComboBox" class="ColumnMappingComboBoxStyle">

            // append the sortable widget HTML code
            _element.append($.parseHTML(_htmlCodeStr));

            // .ColumnMappingStrField element   // the place holder for the dn result string real and display element 
            _columnMappingStrFieldElement = _element.find(".ColumnMappingStrField");
            _columnMappingStrFieldDisplayElement = _columnMappingStrFieldElement.find(".ColumnMappingStrFieldDisplay");
            _columnMappingStrFieldRealElement = _columnMappingStrFieldElement.find(".ColumnMappingStrFieldReal");
            _columnMappingEditBtnElement = _columnMappingStrFieldElement.find(".ColumnMappingEditBtn");

            // .ColumnMappingHeaderLabel element
            _columnMappingHeaderLabelElement = _element.find(".ColumnMappingHeaderLabel");
            _leftColumnHeaderLabelElement = _columnMappingHeaderLabelElement.find(".LeftColumnHeaderLabel");
            _leftAndRightSeparatorHeaderLabelElement = _columnMappingHeaderLabelElement.find(".LeftAndRightSeparatorHeaderLabel");
            _rightColumnHeaderLabelElement = _columnMappingHeaderLabelElement.find(".RightColumnHeaderLabel");
            _componentSeparatorHeaderLabelElement = _columnMappingHeaderLabelElement.find(".ComponentSeparatorHeaderLabel");
            // HeaderLabelElement value
            _leftColumnHeaderLabelStrDisplay = inputLeftColumnHeaderLabelStrDisplay;
            _leftAndRightSeparatorHeaderLabelStrDisplay = inputLeftAndRightSeparatorHeaderLabelStrDisplay;
            _rightColumnHeaderLabelStrDisplay = inputRightColumnHeaderLabelStrDisplay;
            _componentSeparatorHeaderLabelStrDisplay = inputComponentSeparatorHeaderLabelStrDisplay;
            // IsShowedHeaderLabelElement value
            _isShowedLeftColumnHeaderLabelStrDisplay = inputIsShowedLeftColumnHeaderLabelStrDisplay;
            _isShowedLeftAndRightSeparatorHeaderLabelStrDisplay = inputIsShowedLeftAndRightSeparatorHeaderLabelStrDisplay;
            _isShowedRightColumnHeaderLabelStrDisplay = inputIsShowedRightColumnHeaderLabelStrDisplay;
            _isShowedComponentSeparatorHeaderLabelStrDisplay = inputIsShowedComponentSeparatorHeaderLabelStrDisplay;

            // .ColumnMappingWidget element  // the component template to clone  
            _columnMappingWidgetElement = _element.find(".ColumnMappingWidget");
            // .SortableWidgetItem element
            _sortableWidgetItemElement = _columnMappingWidgetElement.find(".SortableWidgetTemplate").find(".SortableWidgetItem");
            _leftAndRightSeparatorDisplayElement = _sortableWidgetItemElement.find(".LeftAndRightSeparatorDisplay");
            _leftAndRightSeparatorRealElement = _sortableWidgetItemElement.find(".LeftAndRightSeparatorReal");
            _leftAndRightSeparatorSelectValuesDisplayElement = _sortableWidgetItemElement.find(".LeftAndRightSeparatorSelectValuesDisplay");
            _componentSeparatorDisplayElement = _sortableWidgetItemElement.find(".ComponentSeparatorDisplay");

            // .SortableWidget element  // the cloned component object place holder
            _sortableWidgetElement = _columnMappingWidgetElement.find(".SortableWidgetPlaceHolder").find(".SortableWidget");
            _sortableWidgetWidth = inputSortableWidgetWidth.toString(); // E.g. "581px"
            _sortableWidgetElement.css({ "float": "left", "width": _sortableWidgetWidth });   // E.g.  _sortableWidgetElement.css({ "float": "left", "width": "581px" })

            // .SortableWidgetBtnsPlaceHolder element   // the btns place holder
            _sortableWidgetBtnsPlaceHolderElement = _columnMappingWidgetElement.find(".SortableWidgetBtnsPlaceHolder");
            _sortableWidgetAddBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetAddBtn");
            _sortableWidgetCommitBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCommitBtn");
            _sortableWidgetClearBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetClearBtn");
            _sortableWidgetCancelBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCancelBtn");
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element ~~~~~~~~~~~~~~~~~~~~~


            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~
            // tip string
            _dragBtnTipStr = inputDragBtnTipStr;
            _removeBtnTipStr = inputRemoveBtnTipStr;
            _editBtnTipStr = inputEditBtnTipStr;
            _addBtnTipStr = inputAddBtnTipStr;
            _commitBtnTipStr = inputCommitBtnTipStr;
            _clearBtnTipStr = inputClearBtnTipStr;
            _cancelBtnTipStr = inputCancelBtnTipStr;
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~


            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~
            // CallBack Event
            _beforeEdit = beforeEdit;
            _afterEdit = afterEdit;
            _beforeAddComponent = beforeAddComponent;
            _afterAddComponent = afterAddComponent;
            _beforeCommit = beforeCommit;
            _afterCommit = afterCommit;
            _beforeClearComponent = beforeClearComponent;
            _afterClearComponent = afterClearComponent;
            _beforeCancel = beforeCancel;
            _afterCancel = afterCancel;
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~

            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~
            _isShowedComponentSeparator = inputIsShowedComponentSeparator;  //  is Showed ComponentSeparator
            _isShowedleftAndRightSeparator = inputIsShowedleftAndRightSeparator;    //  is Showed leftAndRightSeparator

            _isShowedRemoveBtn = inputIsShowedRemoveBtn;    //  is Showed RemoveBtn
            _isShowedLeftColumnTextboxDisplay = inputIsShowedLeftColumnTextboxDisplay;  //  is Showed LeftColumnTextboxDisplay
            _isShowedLeftColumnTextbox = inputIsShowedLeftColumnTextbox;    //  is Showed LeftColumnTextbox
            _isShowedRightColumnTextboxDisplay = inputIsShowedRightColumnTextboxDisplay;    //  is Showed RightColumnTextboxDisplay
            _isShowedRightColumnTextbox = inputIsShowedRightColumnTextbox;  //  is Showed RightColumnTextbox
            _isShowedAddBtn = inputIsShowedAddBtn;  //  is Showed AddBtn
            _isShowedCommitBtn = inputIsShowedCommitBtn;    //  is Showed CommitBtn
            _isShowedClearBtn = inputIsShowedClearBtn;  //  is Showed ClearBtn
            _isShowedCancelBtn = inputIsShowedCancelBtn;    //  is Showed CancelBtn
            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~


            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   value setting ~~~~~~~~~~~~~~~~~~~~~
            _mappingStr = inputMappingStr;    // initial mapping String 
            _escapedSymbolsArr = inputEscapedSymbolsArr; // Escaped symbols array.  All the symbol which should add escape in right column Textbox    // E.g. _escapedSymbolsArr = ["+", "=", ",", "[", "]", "@"];
            // ColumnType
            var _leftColumnType = inputLeftColumnType;    // string  // E.g. columnType.dnHeaderColumnEditableDropdown.toString(),
            var _rightColumnType = inputRightColumnType;   // string  //E.g. columnType.dnValueColumnEditableDropdown.toString(),
            var _componentSeparatorColumnType = inputComponentSeparatorColumnType;  // stgring // E.g. columnType.dnComponentSeparatorColumn.toString(),

            // _leftColumnType attribute settings
            switch (_leftColumnType) {
                case columnTypeEnum().columnType.editableDropdown.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = true;
                    _leftColumnAttributes.isTextboxReadOnly = false;
                    _leftColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false;                     // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false;  // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;  // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.editableDropdownValidValue.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = true;
                    _leftColumnAttributes.isTextboxReadOnly = false;
                    _leftColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    _leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    _leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.editableDropdownValidValueCopyToOther.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = true;
                    _leftColumnAttributes.isTextboxReadOnly = false;
                    _leftColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    _leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    _leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = true; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dropdownCopyToOther.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = true;
                    _leftColumnAttributes.isTextboxReadOnly = true;
                    _leftColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = true; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dropdown.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = true;
                    _leftColumnAttributes.isTextboxReadOnly = true;
                    _leftColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.autocompleteTextbox.toString():
                    _leftColumnAttributes.enableAutoComplete = true;
                    _leftColumnAttributes.isShownDropdownBtn = false;
                    _leftColumnAttributes.isTextboxReadOnly = false;
                    _leftColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.textbox.toString():
                    _leftColumnAttributes.enableAutoComplete = false;
                    _leftColumnAttributes.isShownDropdownBtn = false;
                    _leftColumnAttributes.isTextboxReadOnly = false;
                    _leftColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dnHeaderColumnEditableDropdown.toString():
                    _leftColumnAttributes.enableAutoComplete = true; // bool // is the column autocomplete on or off?
                    _leftColumnAttributes.isShownDropdownBtn = true; // bool // is the dropdown btn show or not?
                    _leftColumnAttributes.isTextboxReadOnly = false; // bool, // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
                    _leftColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_leftColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_leftColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _leftColumnAttributes.enableEscapedSymbol = true; // bool // true, then textbox will add "\" to string in this column
                    _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField = true; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    _leftColumnAttributes.enableCheckIfFieldAndHideOtherColumns = true; // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _leftColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                default:
            }

            // _rightColumnType attribute settings
            switch (_rightColumnType) {
                case columnTypeEnum().columnType.editableDropdown.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = true;
                    _rightColumnAttributes.isTextboxReadOnly = false;
                    _rightColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.editableDropdownValidValue.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = true;
                    _rightColumnAttributes.isTextboxReadOnly = false;
                    _rightColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    _rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    _rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.editableDropdownValidValueCopyToOther.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = true;
                    _rightColumnAttributes.isTextboxReadOnly = false;
                    _rightColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    _rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    _rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = true; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dropdownCopyToOther.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = true;
                    _rightColumnAttributes.isTextboxReadOnly = true;
                    _rightColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = true; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dropdown.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = true;
                    _rightColumnAttributes.isTextboxReadOnly = true;
                    _rightColumnAttributes.isValuseMustValid = true; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.autocompleteTextbox.toString():
                    _rightColumnAttributes.enableAutoComplete = true;
                    _rightColumnAttributes.isShownDropdownBtn = false;
                    _rightColumnAttributes.isTextboxReadOnly = false;
                    _rightColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.textbox.toString():
                    _rightColumnAttributes.enableAutoComplete = false;
                    _rightColumnAttributes.isShownDropdownBtn = false;
                    _rightColumnAttributes.isTextboxReadOnly = false;
                    _rightColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    //_rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    //_rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = false; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = false; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = false;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                case columnTypeEnum().columnType.dnValueColumnEditableDropdown.toString():
                    _rightColumnAttributes.enableAutoComplete = true; // bool // is the column autocomplete on or off?
                    _rightColumnAttributes.isShownDropdownBtn = true; // bool // is the dropdown btn show or not?
                    _rightColumnAttributes.isTextboxReadOnly = false; // bool, // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
                    _rightColumnAttributes.isValuseMustValid = false; // bool // is the value of this column must in the array? false means the value must be one of item in that array.
                    // _rightColumnAttributes.isValuseMustValidTooltipDuration = 2000; // m-second, million second     // if (isValuseMustValid) then set the duration of tooltip open time .
                    // _rightColumnAttributes.isValuseMustValidTooltipMessage = " is not a valid value."; // string //the message for tooltip if (isValuseMustValid)
                    _rightColumnAttributes.enableEscapedSymbol = true; // bool // true, then textbox will add "\" to string in this column
                    _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField = true; // bool // true, then textbox will add "\" to string in this column, but if it is field   e.g. @FieldC  or  [FieldD],  then do not add "\" in front of field.
                    // _rightColumnAttributes.enableCheckIfFieldAndHideOtherColumns = true;    // bool // true, then check if this column is field, which might means e.g. @FieldC  or  [FieldD], then hide neighbor column.
                    _rightColumnAttributes.enableCopyValueToNeighbour = false; // bool // true, then it will copy the value of this column to its neighbor column after autocomplete change.
                    break;
                default:
            }

            // _componentSeparatorColumnType attribute settings
            switch (_componentSeparatorColumnType) {
                case columnTypeEnum().columnType.copyToMappingComponentSeparatorColumn.toString():
                    _componentSeparatorColumnAttributes.isHideButStillSerialise = true; // bool // is component separator hide, and it is still serialised included.               // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
                    break;
                case columnTypeEnum().columnType.searchForMappingComponentSeparatorColumn.toString():
                    _componentSeparatorColumnAttributes.isHideButStillSerialise = true; // bool // is component separator hide, and it is still serialised included.               // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
                    break;
                case columnTypeEnum().columnType.joinMappingComponentSeparatorColumn.toString():
                    _componentSeparatorColumnAttributes.isHideButStillSerialise = true; // bool // is component separator hide, and it is still serialised included.                   // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
                    break;
                case columnTypeEnum().columnType.dnComponentSeparatorColumn.toString():
                    _componentSeparatorColumnAttributes.isHideButStillSerialise = false; // bool // component separator show, and it still serialised.
                    break;
                case columnTypeEnum().columnType.sequenceComponentSeparatorColumn.toString():
                    _componentSeparatorColumnAttributes.isHideButStillSerialise = true; // bool // is component separator hide, and it is still serialised included.                   // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
                    break;
                default:
            }

            if (_isShowedComponentSeparator) {
                // _componentSeparatorDisplayElement = _sortableWidgetItemElement.find(".ComponentSeparatorDisplay");
                _componentSeparatorColumnAttributes.isHideButStillSerialise = false; // bool // is component separator hide, and it is still serialised included.                   // str  // if(displayStr!== "") then show the displayStr instead of showing the real value.
            } else {
                _componentSeparatorColumnAttributes.isHideButStillSerialise = true; // bool // component separator show, and it still serialised.
            }
            // ~~~~~~~~~~~~~~~~~~~~~ End of   value setting ~~~~~~~~~~~~~~~~~~~~~


            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   column attribute setting ~~~~~~~~~~~~~~~~~~~~~
            // .ColumnMappingStrField attribute   // the place holder for the dn result string real and display element 
            _isAlwaysShownColumnMappingStrFieldDisplay = inputIsAlwaysShownColumnMappingStrFieldDisplay;    // show or hide the _columnMappingStrFieldDisplayElement which class=".ColumnMappingStrFieldDisplay".
            if (_isAlwaysShownColumnMappingStrFieldDisplay) {
                _columnMappingStrFieldDisplayElement.addClass("isAlwaysShownColumnMappingStrFieldDisplay");
            }

            // leftColumn attribute
            _leftColumnDataArr = inputLeftColumnDataArr; // E.g. ["DC", "CN", "OU", "O", "STREET", "L", "ST", "C", "UID", "[FieldC]", "@FieldD"];

            // leftAndRightSeparator attribute
            _leftAndRightSeparatorAttributes.leftAndRightSeparatorType = inputLeftAndRightSeparatorType;
            _leftAndRightSeparatorAttributes.strDisplayInColumnMappingStrFieldDisplay = inputLeftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay;
            _leftAndRightSeparatorAttributes.strDisplay = inputLeftAndRightSeparatorStrDisplay;
            _leftAndRightSeparatorAttributes.strReal = inputLeftAndRightSeparatorStrReal;
            _leftAndRightSeparatorAttributes.selectValuesDisplayArr = inputLeftAndRightSeparatorselectValuesDisplayArr;
            _leftAndRightSeparatorAttributes.selectValuesDisplayArrInColumnMappingStrFieldDisplay = inputLeftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay;
            _leftAndRightSeparatorAttributes.selectValuesRealArr = inputLeftAndRightSeparatorSelectValuesRealArr;
            _leftAndRightSeparatorAttributes.indexOfSelectDefaultValue = inputLeftAndRightSeparatorIndexOfSelectDefaultValue;

            // rightColumn attribute
            _rightColumnDataArr = inputRightColumnDataArr; // ["Bob", "Unify", "Chris21", "Smith", "Kevin"];

            // componentSeparatorColumn attribute
            _componentSeparatorColumnAttributes.displayStr = inputComponentSeparatorStrDisplay;    // if (inputComponentSeparatorStrDisplay !== "") then display the componentSeparatorStrDisplay and hide the real value.
            _lastComponentSeparatorDefaultValue = inputLastComponentSeparatorDefaultValue; // Last component separator default value  E.g.  _lastComponentSeparatorDefaultValue = ",";
            _componentSeparatorDataArr = inputComponentSeparatorDataArr; // Component separator data array.  E.g. _componentSeparatorDataArr = [",", "+"];</param>
            _componentSeparatorStyle = inputComponentSeparatorStyle;    // add style to component separator  E.g. "," , "+"   // var _componentSeparatorStyle = { "font-weight": "bold", "color": "blue", "font-size": "20px" }
            // ~~~~~~~~~~~~~~~~~~~~~ End of   column attribute setting ~~~~~~~~~~~~~~~~~~~~~

            return this;
        };  // End of   mappingStrFactory(inputElementID, inputMappingStr, inputIsAlwaysShownColumnMappingStrFieldDisplay, inputComponentSeparatorStyle, inputLeftColumnDataArr, inputRightColumnDataArr, inputLastComponentSeparatorDefaultValue, inputIsShowedComponentSeparator, inputComponentSeparatorDataArr, inputEscapedSymbolsArr, beforeEdit, afterEdit, beforeAddComponent, afterAddComponent, beforeCommit, afterCommit, beforeClearComponent, afterClearComponent, beforeCancel, afterCancel)     // End of       this.construct = function (inputElementID, inputMappingStr, inputComponentSeparatorStyle, inputLeftColumnDataArr, inputRightColumnDataArr, inputLastComponentSeparatorDefaultValue, inputComponentSeparatorDataArr, inputEscapedSymbolsArr, beforeEdit, afterEdit, beforeAddComponent, afterAddComponent, beforeCommit, afterCommit, beforeClearComponent, afterClearComponent, beforeCancel, afterCancel) 
        // -------------------------------------- End of     Constructor --------------------------------------




        /// <summary>
        ///     Deserialize from component arr to sortable SortableWidgetItem
        ///     E.g.
        ///     inputComponentArr === { "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  , "CN=Chris21"  ,  "Protocol=LDAP" }
        ///     componentSeparatorArr === { ","  ,  ","  ,   ","} ===  { ","  ,  ","  ,  , inputLastComponentSeparatorDefaultValue } 
        ///     componentArrLength === 3
        ///     Foreach inputComponentArr
        ///         use 
        ///             if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.labelDisplay.toString())  
        ///                 leftAndRightSeparatorStrReal = "="
        ///         OR
        ///             if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) 
        ///                 leftAndRightSeparatorSelectValuesRealArr = ["::AdapterToLocker::", "::LockerToAdapter::", "::Bidirectional::"]
        ///
        ///         In this case it will run    leftAndRightSeparatorStrReal = "="
        ///         In order to separate the inputComponentArr   into   leftColumnAndSeparatorAndRightColumn
        ///         Therefore
        ///         leftColumnAndSeparatorAndRightColumn[0] === "DC"
        ///         leftColumnAndSeparatorAndRightColumn[1] === "="
        ///         leftColumnAndSeparatorAndRightColumn[2] === "\[kevin\]\+Bob\=Kevin\,Bob\@unify"
        ///         componentSeparatorArr[i] === ","
        ///         Run    cloneComponent(leftColumnAndSeparatorAndRightColumn[0], leftColumnAndSeparatorAndRightColumn[1], leftColumnAndSeparatorAndRightColumn[2], componentSeparatorArr[i]);
        /// </summary>
        /// <param name="inputComponentArr">input component array. E.g. {"DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  , "CN=Chris21"  ,  "Protocol=LDAP"}</param>
        /// <param name="componentSeparatorArr">component separator array.  E.g. { ","  ,  ","  ,   ","}</param>
        /// <param name="componentArrLength">Length of component array.  E.g. 3</param>
        var deserializeComponentArrToSortableWidget = function (inputComponentArr, componentSeparatorArr, componentArrLength) {
            for (var i = 0; i < componentArrLength; i++) {
                /// toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay(inputComponentStr) 
                ///     1. inputComponentStr : input component string.  E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify   
                ///     2. Return:
                ///         [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte, leftAndRightSeparatorStrInColumnMappingStrFieldDisplay]
                ///         E.g. [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify', '<span style="color: blue;font-weight:bold;font-size:20px">=</span>' ]
                var leftColumnAndSeparatorAndRightColumn = toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay(inputComponentArr[i]);
                cloneComponent(leftColumnAndSeparatorAndRightColumn[0], leftColumnAndSeparatorAndRightColumn[1], leftColumnAndSeparatorAndRightColumn[2], componentSeparatorArr[i]);;
            }
        }; // End of    deserializeComponentArrToSortableWidget(inputComponentArr, componentSeparatorArr, componentArrLength)    // End of   var deserializeComponentArrToSortableWidget = function (inputComponentArr, componentSeparatorArr, componentArrLength)


        /// <summary>
        ///     Hide the last component separator and show all other component separator.
        ///     Hide Component Separator DropDown PlaceHolder (E.g. , +) when this is the last Component.
        ///     and show Component Separator DropDown PlaceHolder (E.g. , +) when this is not the last Component.
        /// </summary>
        var hideLastComponentSeparator = function () {
            var clonedComponentSeparatorCollection = _element.find(".ColumnMappingWidget").find(".SortableWidgetPlaceHolder").find(".SortableWidget").find(".ClonedComponentSeparatorPlaceHolder");
            var lastItem;
            clonedComponentSeparatorCollection.each(function () {
                if (_componentSeparatorColumnAttributes.isHideButStillSerialise) {
                    lastItem = $(this).hide(); // hide() every item
                } else {
                    lastItem = $(this).show(); // show() every item
                }
            });
            if (lastItem != null) lastItem.hide(); // hide() the last item
        }; // End of    hideLastComponentSeparator() // End of   var hideLastComponentSeparator = function ()


        /// <summary>
        ///     Make sortable for SortableWidget in SortableWidgetPlaceHolder.
        ///     This method make Component become SortableWidget.
        /// </summary>
        var makeSortableWidget = function () {
            _sortableWidgetElement.sortable({
                // cancel: ".ui-state-disabled",
                // placeholder: "sortableItemPlaceHolder",  // vertical
                axis: "y", // vertical
                start: function (event, ui) {
                    if ($(".ui-autocomplete").length != 0) {
                        //if it exist
                        $(".ui-autocomplete").hide(); // hide the .ui-autocomplete
                    }
                },
                tolerance: "pointer",
                stop: function (event, ui) {
                    hideLastComponentSeparator();
                }
            });
            // _sortableWidgetElement.disableSelection();
            // Disable selection of text content within the set of matched elements.
            // Disable the user to select the text from the sortable item
        }; // End of    makeSortableWidget()    // End of   var makeSortableWidget = function ()


        /// <summary>
        ///     Hide or Show the main buttons whcih includes 
        ///     "Add button", "Commit button", "Clear button", "Cancel button"
        /// </summary>
        var hideOrShowMainBtns = function () {
            // Add button - hide or show
            if (_isShowedAddBtn) {
                _sortableWidgetAddBtnElement.show();
            } else {
                _sortableWidgetAddBtnElement.hide();
            }
            // Commit button - hide or show
            if (_isShowedCommitBtn) {
                _sortableWidgetCommitBtnElement.show();
            } else {
                _sortableWidgetCommitBtnElement.hide();
            }
            // Add button - hide or show
            if (_isShowedClearBtn) {
                _sortableWidgetClearBtnElement.show();
            } else {
                _sortableWidgetClearBtnElement.hide();
            }
            // Cancel button - hide or show
            if (_isShowedCancelBtn) {
                _sortableWidgetCancelBtnElement.show();
            } else {
                _sortableWidgetCancelBtnElement.hide();
            }
        };


        /// <summary>
        ///     Hide or show the target elements.
        ///     if(isHide){hide the target elements}else{show the target elements}
        /// </summary>
        /// <param name="isHide">isHide.</param>
        /// <param name="targetElementArr">targetElementArr.</param>
        var hideORshowTheTargetElements = function (isHide, targetElementArr) {
            for (var i = 0; i < targetElementArr.length; i++) (isHide) ? targetElementArr[i].hide() : targetElementArr[i].show();
        };  // End of   hideORshowTheTargetElements(isHide, targetElementArr)   // End of   var hideORshowTheTargetElements = function (isHide, targetElementArr)


        /// <summary>
        ///     Set the html text to header label in ColumnMappingHeaderLabel element.
        /// </summary>
        var setColumnMappingHeaderLabelText = function () {
            _leftColumnHeaderLabelElement.html(_leftColumnHeaderLabelStrDisplay);
            _leftAndRightSeparatorHeaderLabelElement.html(_leftAndRightSeparatorHeaderLabelStrDisplay);
            _rightColumnHeaderLabelElement.html(_rightColumnHeaderLabelStrDisplay);
            _componentSeparatorHeaderLabelElement.html(_componentSeparatorHeaderLabelStrDisplay);
        };  // End of   setColumnMappingHeaderLabelText()


        /// <summary>
        ///     hide or show the header label in ColumnMappingHeaderLabel element.
        /// </summary>
        var hideOrShowColumnMappingHeaderLabelText = function () {
            if (_isShowedLeftColumnHeaderLabelStrDisplay) {
                _leftColumnHeaderLabelElement.show();
            } else {
                _leftColumnHeaderLabelElement.hide();
            }
            if (_isShowedLeftAndRightSeparatorHeaderLabelStrDisplay) {
                _leftAndRightSeparatorHeaderLabelElement.show();
            } else {
                _leftAndRightSeparatorHeaderLabelElement.hide();
            }
            if (_isShowedRightColumnHeaderLabelStrDisplay) {
                _rightColumnHeaderLabelElement.show();
            } else {
                _rightColumnHeaderLabelElement.hide();
            }
            if (_isShowedComponentSeparatorHeaderLabelStrDisplay) {
                _componentSeparatorHeaderLabelElement.show();
            } else {
                _componentSeparatorHeaderLabelElement.hide();
            }
        };  // End of   hideOrShowColumnMappingHeaderLabelText()


        /// <summary>
        ///     hide the header label in ColumnMappingHeaderLabel element.
        /// </summary>
        var hideColumnMappingHeaderLabelText = function () {
            _leftColumnHeaderLabelElement.hide();
            _leftAndRightSeparatorHeaderLabelElement.hide();
            _rightColumnHeaderLabelElement.hide();
            _componentSeparatorHeaderLabelElement.hide();
        };  // End of   hideColumnMappingHeaderLabelText()


        /// <summary>
        ///     set the cursor of the target textbox to the end when focus
        /// </summary>
        /// <param name="targetTextbox">target textbox.</param>
        var setTextBoxCursorToEndWhenFocus = function (targetTextbox) {
            var domObject = targetTextbox[0];
            targetTextbox.on('focus', function () {
                var targetTextboxLength = targetTextbox.val().length;
                if (domObject.setSelectionRange) {
                    domObject.setSelectionRange(targetTextboxLength, targetTextboxLength);
                }
            });
        };  // End of   SetTextBoxCursorToEndWhenFocus()


        // ------------ Begin of    cloneComponent = function (inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr) ------------
        /// <summary>
        ///     Clone SortableWidgetItem by inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, and inputComponentSeparatorStr
        ///     E.g 1.
        ///     inputLeftColumnStr === "DC"
        ///     inputLeftAndRightSeparatorStr = "="
        ///     inputRightColumnStr === "\[kevin\]\+Bob\=Kevin\,Bob\@unify"  
        ///     inputComponentSeparatorStr === "+"
        ///     Then:
        ///     Create a SortableWidgetItem with all value
        ///     E.g 2.
        ///     inputLeftColumnStr === ""
        ///     inputLeftAndRightSeparatorStr = ""
        ///     inputRightColumnStr === ""  
        ///     inputComponentSeparatorStr === ""
        ///     Then:
        ///     Create a SortableWidgetItem with no value
        /// </summary>
        /// <param name="inputLeftColumnStr">Single left column string.</param>
        /// <param name="inputLeftAndRightSeparatorStr">Left and right separator string.</param>
        /// <param name="inputRightColumnStr">Single right column string.</param>
        /// <param name="inputComponentSeparatorStr">Single component separator string</param>
        var cloneComponent = function (inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr) {
            // ~~~~~~~ Begin of    All cloneComponent Defination ~~~~~~~
            // add .Cloned...  class to every sub element.
            var clonedSortableWidgetItem = _sortableWidgetItemElement.eq(0).clone();
            clonedSortableWidgetItem = clonedSortableWidgetItem.addClass("ClonedSortableWidgetItem");

            var sortableWidgetItemDragBtn = clonedSortableWidgetItem.find(".SortableWidgetItemDragBtn").addClass("ClonedSortableWidgetItemDragBtn");

            var leftColumnTextboxDisplay = clonedSortableWidgetItem.find(".LeftColumnTextboxDisplay").addClass("ClonedLeftColumnTextboxDisplay");
            var leftColumnTextbox = clonedSortableWidgetItem.find(".LeftColumnTextbox").addClass("ClonedLeftColumnTextbox");
            var leftColumnDropdownBtn = clonedSortableWidgetItem.find(".LeftColumnDropdownBtn").addClass("ClonedLeftColumnDropdownBtn");
            var wasleftColumnDropdownOpen = false;

            var leftAndRightSeparatorDisplayElement = clonedSortableWidgetItem.find(".LeftAndRightSeparatorDisplay").addClass("ClonedLeftAndRightSeparatorDisplay");
            var leftAndRightSeparatorRealElement = clonedSortableWidgetItem.find(".LeftAndRightSeparatorReal").addClass("ClonedLeftAndRightSeparatorReal");
            var leftAndRightSeparatorSelectValuesDisplayElement = clonedSortableWidgetItem.find(".LeftAndRightSeparatorSelectValuesDisplay").addClass("ClonedLeftAndRightSeparatorSelectValuesDisplay");

            var rightColumnTextboxDisplay = clonedSortableWidgetItem.find(".RightColumnTextboxDisplay").addClass("ClonedRightColumnTextboxDisplay");
            var rightColumnTextbox = clonedSortableWidgetItem.find(".RightColumnTextbox").addClass("ClonedRightColumnTextbox");
            var rightColumnDropdownBtn = clonedSortableWidgetItem.find(".RightColumnDropdownBtn").addClass("ClonedRightColumnDropdownBtn");
            var wasRightColumnDropdownOpen = false;

            var componentSeparator = clonedSortableWidgetItem.find(".ComponentSeparator").addClass("ClonedComponentSeparator");
            var componentSeparatorPlaceHolder = clonedSortableWidgetItem.find(".ComponentSeparatorPlaceHolder").addClass("ClonedComponentSeparatorPlaceHolder");

            var componentRemoveBtn = clonedSortableWidgetItem.find(".ComponentRemoveBtn").addClass("ClonedComponentRemoveBtn");
            // ~~~~~~~ End of    All cloneComponent Defination ~~~~~~~

            // add tool tip
            // addTooltip(sortableWidgetItemDragBtn, _dragBtnTipStr); // jquery ui tool tip
            // addTooltip(componentRemoveBtn, _removeBtnTipStr); // jquery ui tool tip 
            sortableWidgetItemDragBtn.attr("title", _dragBtnTipStr);
            componentRemoveBtn.attr("title", _removeBtnTipStr);


            // ~~~~~~~ Begin of    leftColumnTextbox  ~~~~~~~
            // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
            if (_leftColumnAttributes.isTextboxReadOnly) leftColumnTextbox.attr('readonly', true);

            // leftColumnTextbox
            // If user select or type"[FieldC]" or "@fieldC", then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
            function leftColumnTextboxChangeHandler(event, leftColumnTextboxSelectedValueStr) {
                // if LeftColumn isField === ture, and 
                //      if leftAndRightSeparatorType === selectDropdown
                //          Hide selectDropdownHideOrShowTargetElementsArr
                //      if leftAndRightSeparatorType === labelDisplay
                //          Hide labelDisplayHideOrShowTargetElementsArr
                ifLeftColumnIsFieldAndHideOtherColumns(
                    ((new strSpecialRuleHelper()).setIsFieldAndSetResultStrWithEscapedSymbol(leftColumnTextboxSelectedValueStr, escapedSymbolsArr))._isField,
                    [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorSelectValuesDisplayElement],
                    [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement]);

                if (!_rightColumnAttributes.isShownDropdownBtn) rightColumnDropdownBtn.hide();

                if (_leftColumnAttributes.enableCopyValueToNeighbour) {
                    rightColumnTextbox.val(leftColumnTextbox.val());
                }
            }
            // When user type "[FieldC]" or "@fieldC" manually in leftColumn TextBox, then  hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
            leftColumnTextbox.on('input propertychange paste', function (event) { leftColumnTextboxChangeHandler(event, leftColumnTextbox.val()); });

            // deal with autoComplete
            if (_leftColumnAttributes.enableAutoComplete) {
                // Apply autocomplete : jQueryUiAutocompleteHelper  construct(constructSource, constructMinLength, constructAutoFocus) // addAutocompleteToTargetElement(targetElement) 
                var leftColumnTextboxJQueryUiAutocompleteHelper = new jQueryUiAutocompleteHelper(_leftColumnDataArr, 1, true).addAutocompleteToTargetElement(leftColumnTextbox); // add autocomplete to leftColumnTextbox  

                //check if the autocomplete wasOpen
                function wasLeftColumnAutocompleteDropdownOpen(event) {
                    wasleftColumnDropdownOpen = leftColumnTextboxJQueryUiAutocompleteHelper.setWasTargetElementAutocompleteDropdownOpen(leftColumnTextbox)._wasTargetElementAutocompleteDropdownOpen; // in the leftColumnTextbox, look for the widget autocomplete to see if this widget is visible or not
                }
                $(document).on("mousedown", wasLeftColumnAutocompleteDropdownOpen);

                // Close autocomplete dropdown when blur, blur means when not focus
                // leftColumn
                function leftColumnBlurHandler(event) { wasleftColumnDropdownOpen = leftColumnTextboxJQueryUiAutocompleteHelper.closeTargetElementAutocompleteDropdown(leftColumnTextbox)._wasTargetElementAutocompleteDropdownOpen; }
                // Open autocomplete dropdown when focus
                // leftColumn
                function leftColumnFocusHandler(event) { wasleftColumnDropdownOpen = leftColumnTextboxJQueryUiAutocompleteHelper.openTargetElementAutocompleteDropdown(leftColumnTextbox, leftColumnDropdownBtn)._wasTargetElementAutocompleteDropdownOpen; }
                leftColumnDropdownBtn.on("focus", leftColumnFocusHandler);
                leftColumnDropdownBtn.on("blur", function (event) {
                    var leftColumnTextboxAutoComplete = leftColumnTextbox.autocomplete("widget");
                    if (leftColumnTextboxAutoComplete.is(":focus")) {
                        leftColumnFocusHandler(event);
                    } else {
                        leftColumnBlurHandler(event);
                    }
                });
                leftColumnTextbox.on("blur", function (event) {
                    var leftColumnTextboxAutoComplete = leftColumnTextbox.autocomplete("widget");
                    if (leftColumnTextboxAutoComplete.is(":focus")) {
                        leftColumnFocusHandler(event);
                    } else {
                        leftColumnBlurHandler(event);
                    }
                });


                // click event to handle focus and blur
                // leftColumn
                function leftColumnClickHandler(event) { (wasleftColumnDropdownOpen) ? leftColumnDropdownBtn.blur() : leftColumnDropdownBtn.focus(); }
                leftColumnDropdownBtn.on("click", leftColumnClickHandler);
                // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
                if (_leftColumnAttributes.isTextboxReadOnly) leftColumnTextbox.on("click", leftColumnClickHandler);

                // leftColumnTextbox
                // If user select or type"[FieldC]" or "@fieldC", then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                // If user select "[FieldC]" or "@fieldC" from autoComplete (dropdown), then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                leftColumnTextbox.on("autocompleteselect", function (event, ui) { leftColumnTextboxChangeHandler(event, ui.item.value); });


                // autocompletechange event handler
                function leftAutocompleteChangeHandler(event, targetElement, neighborElement) {
                    // check if the value is valid
                    if (_leftColumnAttributes.isValuseMustValid) {
                        if (!((new strSpecialRuleHelper()).containStrElementInStrArr(_leftColumnDataArr, targetElement.val(), true)._isContainElement)) {
                            // add tooltip and open and close after 2500 m-second
                            (new jQueryUiToolTipHelper()).addToolTipAndOpenWithDuration(targetElement, targetElement.val() + _leftColumnAttributes.isValuseMustValidTooltipMessage, _leftColumnAttributes.isValuseMustValidTooltipDuration);
                            // clear textbox
                            targetElement.val("");
                        }
                    }

                    if (_leftColumnAttributes.enableCopyValueToNeighbour) {
                        neighborElement.val(targetElement.val());
                    }
                }
                leftColumnTextbox.on("autocompletechange", function (event, ui) { leftAutocompleteChangeHandler(event, leftColumnTextbox, rightColumnTextbox); });

            }
            // ~~~~~~~ End of    leftColumnTextbox  ~~~~~~~



            // ~~~~~~~ Begin of    rightColumnTextbox  ~~~~~~~
            function rightColumnTextboxChangeHandler(event, rightColumnTextboxSelectedValueStr) {
                // check if the value is valid
                if (_rightColumnAttributes.enableCopyValueToNeighbour)
                    leftColumnTextbox.val(rightColumnTextbox.val());
            }
            rightColumnTextbox.on('input propertychange paste', function (event) { rightColumnTextboxChangeHandler(event, rightColumnTextbox.val()); });  // leftColumnTextbox changes event

            // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
            if (_rightColumnAttributes.isTextboxReadOnly) rightColumnTextbox.attr('readonly', true);

            // deal with autoComplete
            if (_rightColumnAttributes.enableAutoComplete) {
                // Apply autocomplete : jQueryUiAutocompleteHelper  construct(constructSource, constructMinLength, constructAutoFocus) // addAutocompleteToTargetElement(targetElement) 
                var rightColumnTextboxJQueryUiAutocompleteHelper = new jQueryUiAutocompleteHelper(_rightColumnDataArr, 1, true).addAutocompleteToTargetElement(rightColumnTextbox); // add autocomplete to rightColumnTextbox  

                //check if the autocomplete wasOpen
                function wasRightColumnAutocompleteDropdownOpen(event) {
                    wasRightColumnDropdownOpen = rightColumnTextboxJQueryUiAutocompleteHelper.setWasTargetElementAutocompleteDropdownOpen(rightColumnTextbox)._wasTargetElementAutocompleteDropdownOpen; // in the rightColumnTextbox, look for the widget autocomplete to see if this widget is visible or not
                }
                $(document).on("mousedown", wasRightColumnAutocompleteDropdownOpen);

                // Close autocomplete dropdown when blur, blur means when not focus
                // rightColumn
                function rightColumnBlurHandler(event) { wasRightColumnDropdownOpen = rightColumnTextboxJQueryUiAutocompleteHelper.closeTargetElementAutocompleteDropdown(rightColumnTextbox)._wasTargetElementAutocompleteDropdownOpen; }
                // rightColumn
                function rightColumnFocusHandler(event) { wasRightColumnDropdownOpen = rightColumnTextboxJQueryUiAutocompleteHelper.openTargetElementAutocompleteDropdown(rightColumnTextbox, rightColumnDropdownBtn)._wasTargetElementAutocompleteDropdownOpen; }
                rightColumnDropdownBtn.on("focus", rightColumnFocusHandler);
                rightColumnDropdownBtn.on("blur", function (event) {
                    var rightColumnTextboxAutoComplete = rightColumnTextbox.autocomplete("widget");
                    if (rightColumnTextboxAutoComplete.is(":focus")) {
                        rightColumnFocusHandler(event);
                    } else {
                        rightColumnBlurHandler(event);
                    }
                });
                rightColumnTextbox.on("blur", function (event) {
                    var rightColumnTextboxAutoComplete = rightColumnTextbox.autocomplete("widget");
                    if (rightColumnTextboxAutoComplete.is(":focus")) {
                        rightColumnFocusHandler(event);
                    } else {
                        rightColumnBlurHandler(event);
                    }
                });

                // click event to handle focus and blur
                // rightColumn
                function rightColumnClickHandler(event) { (wasRightColumnDropdownOpen) ? rightColumnDropdownBtn.blur() : rightColumnDropdownBtn.focus(); }
                rightColumnDropdownBtn.on("click", rightColumnClickHandler);
                // is the textbox read only.   // enableAutoComplete: true,  isShownDropdownBtn: true, isTextboxReadOnly: true, isValuseMustValid: true , then it means it is normal dropdown.
                if (_rightColumnAttributes.isTextboxReadOnly) rightColumnTextbox.on("click", rightColumnClickHandler);

                // check autocompletechange event handler
                function rightAutocompleteChangeHandler(event, targetElement) {
                    // check if the value is valid
                    if (_rightColumnAttributes.isValuseMustValid) {
                        if (!((new strSpecialRuleHelper()).containStrElementInStrArr(_rightColumnDataArr, targetElement.val(), true)._isContainElement)) {
                            // add tooltip and open and close after 2500 m-second
                            (new jQueryUiToolTipHelper()).addToolTipAndOpenWithDuration(targetElement, targetElement.val() + _rightColumnAttributes.isValuseMustValidTooltipMessage, _rightColumnAttributes.isValuseMustValidTooltipDuration);
                            // clear textbox
                            targetElement.val("");
                        }
                    }

                    // check if need to copy value to neighbor column
                    if (_rightColumnAttributes.enableCopyValueToNeighbour) {
                        leftColumnTextbox.val(rightColumnTextbox.val());
                    }
                }

                rightColumnTextbox.on("autocompletechange", function (event, ui) { rightAutocompleteChangeHandler(event, rightColumnTextbox); });


                // rightColumnTextbox changes event
                rightColumnTextbox.on("autocompleteselect", function (event, ui) { rightColumnTextboxChangeHandler(event, ui.item.value); });
                // leftColumnTextbox.on("autocompletechange", function (event, ui) { leftAutocompleteChangeHandler(event, leftColumnTextbox, rightColumnTextbox); });
            }
            // ~~~~~~~ End of    rightColumnTextbox  ~~~~~~~

            // leftAndRightSeparatorSelectValuesDisplayElement
            // set up the options for the leftAndRightSelectDropdown 
            for (var i = 0; i < _leftAndRightSeparatorAttributes.selectValuesRealArr.length; i++) {
                leftAndRightSeparatorSelectValuesDisplayElement.append("<option value=\"" + _leftAndRightSeparatorAttributes.selectValuesRealArr[i] + "\">" + _leftAndRightSeparatorAttributes.selectValuesDisplayArr[i] + "</option>");
            }
            var leftAndRightSeparatorValueStr = (inputLeftAndRightSeparatorStr === null || inputLeftAndRightSeparatorStr === "") ? _leftAndRightSeparatorAttributes.selectValuesRealArr[_leftAndRightSeparatorAttributes.indexOfSelectDefaultValue] : inputLeftAndRightSeparatorStr;
            SetSelectDropdownValue(leftAndRightSeparatorSelectValuesDisplayElement, leftAndRightSeparatorValueStr);

            // componentSeparator:  Add item to select menu (E.g.  "," and "+"), then Apply <select> to  jQuery selectmenu
            for (var i = 0; i < _componentSeparatorDataArr.length; i++) componentSeparator.append("<option value=\"" + _componentSeparatorDataArr[i] + "\">" + _componentSeparatorDataArr[i] + "</option>");
            componentSeparator.val(_lastComponentSeparatorDefaultValue);    // E.g. componentSeparator.val(",");  
            componentSeparator.selectmenu({ width: 50 });

            // componentRemoveBtn : Apply component Remove btn click event to destroy autocomplete and off all event, then remove whole component
            componentRemoveBtn.on("click", function (event) {

                // ~~~~~~~ Brgin of    leftColumnTextbox  ~~~~~~~
                // If user select or type"[FieldC]" or "@fieldC", then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                // If user select "[FieldC]" or "@fieldC" from autoComplete (dropdown), then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                leftColumnTextbox.off('input propertychange paste');

                if (_leftColumnAttributes.enableAutoComplete) {
                    leftColumnTextbox.autocomplete("destroy");
                    $(document).off("mousedown", wasLeftColumnAutocompleteDropdownOpen);
                    leftColumnDropdownBtn.off("blur", leftColumnBlurHandler);
                    leftColumnTextbox.off("blur", leftColumnBlurHandler);
                    leftColumnDropdownBtn.off("focus", leftColumnFocusHandler);
                    leftColumnDropdownBtn.off("click", leftColumnClickHandler);
                    if (_leftColumnAttributes.isTextboxReadOnly) leftColumnTextbox.off("click", leftColumnClickHandler);
                    // If user select or type"[FieldC]" or "@fieldC", then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                    // If user select "[FieldC]" or "@fieldC" from autoComplete (dropdown), then hide rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement ( OR  leftAndRightSeparatorSelectValuesDisplayElement)
                    leftColumnTextbox.off("autocompleteselect");
                    // check if the value is valid
                    if (!_leftColumnAttributes.isValuseMustValid) leftColumnTextbox.off("autocompletechange");
                }
                // ~~~~~~~ End of    leftColumnTextbox  ~~~~~~~


                // ~~~~~~~ Begin of    rightColumnTextbox  ~~~~~~~
                if (_rightColumnAttributes.enableAutoComplete) {
                    rightColumnTextbox.autocomplete("destroy");
                    $(document).off("mousedown", wasRightColumnAutocompleteDropdownOpen);
                    rightColumnTextbox.off("blur", rightColumnBlurHandler);
                    rightColumnDropdownBtn.off("blur", rightColumnBlurHandler);
                    rightColumnDropdownBtn.off("focus", rightColumnFocusHandler);
                    rightColumnDropdownBtn.off("click", rightColumnClickHandler);
                    rightColumnTextbox.off("autocompleteselect");
                    if (_rightColumnAttributes.isTextboxReadOnly) rightColumnTextbox.off("click", rightColumnClickHandler);
                }
                // ~~~~~~~ End of    rightColumnTextbox  ~~~~~~~

                clonedSortableWidgetItem.remove();
                hideLastComponentSeparator();
            });


            // sortableWidgetPlaceHolder  
            _sortableWidgetElement.append(clonedSortableWidgetItem);    // append the Cloned Component (SortableWidgetItem) to      .SortableWidgetPlaceHolder .SortableWidget
            hideLastComponentSeparator();   // Hide Component Separator (E.g. + ,) DropDown PlaceHolder when this is the last Component, and Show Component Separator (E.g. + ,) DropDown PlaceHolder when this is not the last Component

            // ~~~~~~~~~~~~~~~~~~ Begin of     Deserialization, convert mapping string to SortableWidget ~~~~~~~~~~~~~~~~~~
            leftColumnTextbox.val(inputLeftColumnStr); // Set leftColumnTextbox
            rightColumnTextbox.val(inputRightColumnStr); // Set rightColumnTextbox

            if (inputComponentSeparatorStr !== "") {
                // Set Component Separator in both Dropdown, and jQuery ui dropdown.
                componentSeparatorPlaceHolder.find(".ui-selectmenu-text").html(inputComponentSeparatorStr); // Set Component Separator   jQuery UI SelectMenu
                componentSeparator.val(inputComponentSeparatorStr); // Set ComponentSeparatorDropDown
            }

            // For Example 01:
            //      DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP
            //      Look at the first component,     DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify
            //      cloneComponent("DC" , "=", "[kevin]+Bob=Kevin,Bob@unify" , "," )     
            //      cloneComponent(inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr)
            //      inputLeftColumnStr = "DC"
            //      inputLeftAndRightSeparatorStr = "="
            //      inputRightColumnStr = "[kevin]+Bob=Kevin,Bob@unify"
            //      inputComponentSeparatorStr = ","
            //      Then it will create a SortableWidgetItem with all value
            if (inputLeftColumnStr != "") {
                // if LeftColumn isField === ture, and 
                //      if leftAndRightSeparatorType === selectDropdown
                //          Hide selectDropdownHideOrShowTargetElementsArr
                //      if leftAndRightSeparatorType === labelDisplay
                //          Hide labelDisplayHideOrShowTargetElementsArr
                ifLeftColumnIsFieldAndHideOtherColumns(
                    ((inputRightColumnStr === "") && (((new strSpecialRuleHelper()).setIsFieldAndSetResultStrWithEscapedSymbol(inputLeftColumnStr, _escapedSymbolsArr))._isField)),
                    [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorSelectValuesDisplayElement],
                    [rightColumnTextbox, rightColumnDropdownBtn, leftAndRightSeparatorDisplayElement]);
            }
            // ~~~~~~~~~~~~~~~~~~ End of     Deserialization, convert mapping string to SortableWidget ~~~~~~~~~~~~~~~~~~

            // deal with isShownDropdownBtn
            if (!_leftColumnAttributes.isShownDropdownBtn) leftColumnDropdownBtn.hide();
            if (!_rightColumnAttributes.isShownDropdownBtn) rightColumnDropdownBtn.hide();

            // ~~~~~~~~~~~~~~~~~~ Begin of     Hide and Show ~~~~~~~~~~~~~~~~~~
            // LeftColumnTextbox
            if (_isShowedLeftColumnTextbox) {
                leftColumnTextbox.removeClass("hideElement");
                leftColumnDropdownBtn.removeClass("hideElement");
            } else {
                leftColumnTextbox.addClass("hideElement");
                leftColumnDropdownBtn.addClass("hideElement");
            }
            // LeftColumnTextboxDisplay
            if (_isShowedLeftColumnTextboxDisplay) {
                leftColumnTextboxDisplay.show();
            } else {
                leftColumnTextboxDisplay.hide();
            }

            // leftAndRightSeparator
            if (_isShowedleftAndRightSeparator) {
                if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) {
                    leftAndRightSeparatorDisplayElement.hide();
                    leftAndRightSeparatorSelectValuesDisplayElement.show();
                } else {
                    leftAndRightSeparatorDisplayElement.show();
                    leftAndRightSeparatorSelectValuesDisplayElement.hide();
                }
            } else {
                leftAndRightSeparatorDisplayElement.hide();
                leftAndRightSeparatorSelectValuesDisplayElement.hide();
            }

            // RightColumnTextbox
            if (_isShowedRightColumnTextbox) {
                rightColumnTextbox.removeClass("hideElement");
                rightColumnDropdownBtn.removeClass("hideElement");
            } else {
                rightColumnTextbox.addClass("hideElement");
                rightColumnDropdownBtn.addClass("hideElement");
            }
            // RightColumnTextboxDisplay
            if (_isShowedRightColumnTextboxDisplay) {
                rightColumnTextboxDisplay.show();
            } else {
                rightColumnTextboxDisplay.hide();
            }
            // RemoveBtn
            if (_isShowedRemoveBtn) {
                componentRemoveBtn.show();
            } else {
                componentRemoveBtn.hide();
            }
            // ~~~~~~~~~~~~~~~~~~ End of     Hide and Show ~~~~~~~~~~~~~~~~~~

            setTextBoxCursorToEndWhenFocus(rightColumnTextbox);
            setTextBoxCursorToEndWhenFocus(leftColumnTextbox);
        } // End of  cloneComponent = function (inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr)   // var cloneComponent = function (inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr)
        // ------------ End of    cloneComponent = function (inputLeftColumnStr, inputLeftAndRightSeparatorStr, inputRightColumnStr, inputComponentSeparatorStr) ------------







        /// <summary>
        ///     1.
        ///     Private method 
        ///     clear all component.
        ///     for each component,  trigger componentRemoveBtn click event to remove all component.
        ///     2.
        ///     PS: privateClearAllComponent() method and clearAllComponent() method must be after cloneComponent() method
        /// </summary>
        /// <returns>current object</returns>
        var privateClearAllComponent = function () {
            var removedItem = _columnMappingWidgetElement.find(".SortableWidgetPlaceHolder").find(".SortableWidget").find(".ClonedSortableWidgetItem");
            // for each component,  trigger componentRemoveBtn click event to remove all component.
            removedItem.each(function () {
                var componentRemoveBtn = removedItem.find(".ClonedComponentRemoveBtn");
                componentRemoveBtn.trigger("click");
            });
            return this;
        };  // End of   privateClearAllComponent() // End of   var privateClearAllComponent = function () {


        /// <summary>
        ///     1.
        ///     Plublic method 
        ///     clear all component.
        ///     2.
        ///     PS: privateClearAllComponent() method and clearAllComponent() method must be after cloneComponent() method
        /// </summary>
        /// <returns>current object</returns>
        this.clearAllComponent = function () {
            privateClearAllComponent();
            return this;
        };  // End of   clearAllComponent()   // this.clearAllComponent = function() 


        /// <summary>
        ///     1.
        ///     Private method 
        ///     deserialize mapping string to components
        ///     E.g.
        ///     inputMappingStr  ===    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP
        ///     deserialize to component
        ///     2.
        ///     PS: privateClearAllComponent() method and clearAllComponent() method must be after cloneComponent() method
        ///     privateDeserializeMappingStrToComponent() method and deserializeMappingStrToComponent() method must be after privateClearAllComponent() method and clearAllComponent()
        /// </summary>
        /// <param name="inputMappingStr">input mapping string.</param>
        /// <returns>current object</returns>
        var privateDeserializeMappingStrToComponent = function (inputMappingStr) {
            privateClearAllComponent();    // Clear all Component, before deserializing mapping string to component

            if (inputMappingStr === null || inputMappingStr === "") {
                deserializeComponentArrToSortableWidget("", "", "");
                return this;
            }

            // convertMappingStrToComponentArr will return  [componentArr, componentSeparatorArr, componentArr.length]
            // E.g.
            // inputMappingStr  ===    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP   
            // In this case, it will return
            //      _mappingStrToComponentArr[0] === componentArr === { "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  , "CN=Chris21"  ,  "Protocol=LDAP" }
            //      _mappingStrToComponentArr[1] === componentSeparatorArr === { ","  ,  ","  ,  ","} === { ","  ,  ","  , lastComponentSeparatorDefaultValue } 
            //      _mappingStrToComponentArr[2] === componentArr.length === 3
            var componentArr = convertMappingStrToComponentArr(inputMappingStr);
            deserializeComponentArrToSortableWidget(componentArr[0], componentArr[1], componentArr[2]);
            return this;
        };  // End of   privateDeserializeMappingStrToComponent(inputMappingStr)     // End of   this.privateDeserializeMappingStrToComponent = function (inputMappingStr)


        /// <summary>
        ///     Public method
        ///     deserialize mapping string to components
        /// </summary>
        /// <param name="inputMappingStr">input mapping string.</param>
        /// <returns>current object</returns>
        this.deserializeMappingStrToComponent = function (inputMappingStr) {
            privateDeserializeMappingStrToComponent(inputMappingStr);
            return this;
        }   // End of   deserializeMappingStrToComponent(inputMappingStr)   // End of   this.deserializeMappingStrToComponent = function(inputMappingStr) {


        /// <summary>
        ///     Convert the real mapping string to mappingStrDisplay, and the component separator does not have css style
        /// </summary>
        /// <param name="inputMappingStr">the input mapping string.  E.g. "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP"</param>
        /// <returns>MappingStrDisplay.   E.g. DC=[kevin]+Bob=Kevin,Bob@unify<span>&nbsp;&nbsp;,&nbsp;&nbsp;</span>CN=Chris21<span>&nbsp;&nbsp;+&nbsp;&nbsp;</span>Protocol=LDAP  </returns>
        var convertMappingStrRealToMappingStrDisplay = function (inputMappingStr) {
            var mappingStrDisplay = "";
            if (inputMappingStr === null || inputMappingStr === "") {
                return mappingStrDisplay;
            }

            var mappingStrToComponentArr = convertMappingStrToComponentArr(inputMappingStr);   // [componentArr, componentSeparatorArr, componentArr.length] === [ { "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  , "CN=Chris21"  ,  "Protocol=LDAP" }  ,  { "+"  ,  ","  ,   "+"  ,  "+" , ","}  ,  5]
            var componentArr = mappingStrToComponentArr[0];  // E.g. { "DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify"  ,  "[FieldC]"  ,   "CN=Chris21"  ,  "@FieldD"  ,  "Protocol=LDAP" }
            var componentSeparatorArr = mappingStrToComponentArr[1]; // E.g. { "+"  ,  ","  ,   "+"  ,  "+" , ","} === { "+"  ,  ","  ,   "+"  ,  "+" , lastComponentSeparatorDefaultValue } 
            var componentArrLength = mappingStrToComponentArr[2];   // E.g. componentArr.length === 5 

            // for each Component, get rid of "\" in right column, and 
            // if the Component is the last one, do not add <span> componentSeparatorArr </span>
            for (var i = 0; i < componentArrLength; i++) {
                /// toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay(inputComponentStr) 
                ///     1. inputComponentStr : input component string.  E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify   
                ///     2. Return:
                ///         [leftColumnStrWithoutEscapte, leftAndRightSeparatorStrReal, rightColumnStrWithoutEscapte, leftAndRightSeparatorStrInColumnMappingStrFieldDisplay]
                ///         E.g. [ 'DC' , '=', '[kevin]+Bob=Kevin,Bob@unify', '<span style="color: blue;font-weight:bold;font-size:20px">=</span>' ]
                var leftColumnAndSeparatorAndRightColumn = toLeftColumnAndSeparatorStRealAndRightColumnAndSeparatorStrInColumnMappingStrFieldDisplay(componentArr[i]);
                var leftAndRightSeparatorStrInColumnMappingStrFieldDisplay = leftColumnAndSeparatorAndRightColumn[3];    // the left and right separator display string in ColumnMappingStrFieldDisplay which class="ColumnMappingStrFieldDisplay"

                // left column  + leftAndRightSeparator + right column
                var leftColumnStr = leftColumnAndSeparatorAndRightColumn[0];     // E.g. "DC"
                var rightColumnStr = leftColumnAndSeparatorAndRightColumn[2];    // E.g. "[kevin]+Bob=Kevin,Bob@unify"
                if (rightColumnStr === "") {
                    componentArr[i] = leftColumnAndSeparatorAndRightColumn[0] + leftAndRightSeparatorStrInColumnMappingStrFieldDisplay;   // if componentArr[i]==="@fieldC" , then    componentArr[i] = leftColumnAndSeparatorAndRightColumn[0]; is still === "@fieldC"
                } else {
                    componentArr[i] = leftColumnAndSeparatorAndRightColumn[0] + leftAndRightSeparatorStrInColumnMappingStrFieldDisplay + leftColumnAndSeparatorAndRightColumn[2];   // E.g. "DC" + " insert to " + "[kevin]+Bob=Kevin,Bob@unify"
                }

                // left column  + leftAndRightSeparator + right column + componentSeparator
                var componentSeparatorStrDisplay = componentSeparatorArr[i];
                if (_componentSeparatorColumnAttributes.displayStr !== "") componentSeparatorStrDisplay = _componentSeparatorColumnAttributes.displayStr;

                // Deal with the LAST componentSeparator.
                (i === componentArrLength - 1) ?
                    (mappingStrDisplay = mappingStrDisplay + componentArr[i]) :
                    (mappingStrDisplay = mappingStrDisplay + componentArr[i] + "<span>" + componentSeparatorStrDisplay + "</span>");
            }
            return mappingStrDisplay;
        };  // End of   convertMappingStrRealToMappingStrDisplay(inputMappingStr)  // End of   var convertMappingStrRealToMappingStrDisplay = function(inputMappingStr)


        /// <summary>
        ///     Add Css to componentSeparator(E.g. "+", ",")  of  mappingStrDisplay.
        /// </summary>
        /// <param name="inputMappingStrDisplayWithoutCssForSeparator">MappingStrDisplay without css of componentSeparator</param>
        /// <returns>return current object</returns>
        var addCssToComponentSeparator = function (inputMappingStrDisplayWithoutCssForSeparator) {
            _columnMappingStrFieldDisplayElement.html(inputMappingStrDisplayWithoutCssForSeparator);   // Set the mappingStr on screen
            _columnMappingStrFieldDisplayElement.find("span").css(_componentSeparatorStyle);    // { "font-weight": "bold", "color": "red", "font-size": "20px" }   // in css ,  font-weight: bold; color: blue; font-size: 20px;  // Change the component separator style
            return this;
        };  // End of   addCssToComponentSeparator(inputMappingStrDisplayWithoutCssForSeparator)  // End of   var addCssToComponentSeparator = function (inputMappingStrDisplayWithoutCssForSeparator)


        /// <summary>
        ///     Convert the real mapping string to mappingStrDisplay, and the component separator has css style
        /// </summary>
        /// <param name="inputMappingStr">the mapping string</param>
        /// <returns>return current object</returns>
        var convertMappingStrRealToMappingStrDisplayWithCss = function (inputMappingStr) {
            addCssToComponentSeparator(convertMappingStrRealToMappingStrDisplay(inputMappingStr));
            return this;
        }   // End of   convertMappingStrRealToMappingStrDisplayWithCss(inputMappingStr)   // End of    var convertMappingStrRealToMappingStrDisplayWithCss = function(inputMappingStr)


        // --------------------------------------------------- Begin of    Btn Handler ---------------------------------------------------
        /// <summary>
        ///     Edit btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var editBtnClickHandler = function (event) {
            _beforeEdit(event); // before edit btn click event
            privateDeserializeMappingStrToComponent(_columnMappingStrFieldRealElement.html()); // deserialize mapping string to SortableWidgetItem  // _columnMappingStrFieldRealElement.html()  is mappingStr
            _columnMappingWidgetElement.show(); // show the ColumnMappingWidget
            _columnMappingEditBtnElement.hide(); // Hide the Edit Btn
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.hide(); // hide the .ColumnMappingStrFieldDisplay    
            hideOrShowColumnMappingHeaderLabelText();   // hide or show the header label in ColumnMappingHeaderLabel element.
            _afterEdit(event);  // after edit btn click event
        }; // End of     editBtnClickHandler(event) // End of   var editBtnClickHandler = function(event) {


        /// <summary>
        ///     Add btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var addBtnClickHandler = function (event) {
            _beforeAddComponent(event); // before add btn click event
            cloneComponent("", "", "", "");
            _afterAddComponent(event) // after add btn click event
        }; // End of     addBtnClickHandler(event)    // End of   var addBtnClickHandler = function (event) {


        /// <summary>
        ///     Commit btn click handler
        ///     it will produce the mappingStrReal and mappingStrRealDisplay,
        ///     then mappingStrReal will have to do replaceWithEscapedSymbol
        /// </summary>
        /// <param name="event">Event.</param>
        var commitBtnClickHandler = function (event) {
            _beforeCommit(event);   // before commit btn click event

            var mappingStrReal = "";
            var mappingStrDisplay = "";
            var clonedLeftColumnTextboxCollection = _sortableWidgetElement.find(".ClonedLeftColumnTextbox");
            var clonedRightColumnTextboxCollection = _sortableWidgetElement.find(".ClonedRightColumnTextbox");

            var clonedLeftAndRightSeparatorLabelDisplayCollection = _sortableWidgetElement.find(".ClonedLeftAndRightSeparatorDisplay");
            var clonedLeftAndRightSeparatorLabelRealCollection = _sortableWidgetElement.find(".ClonedLeftAndRightSeparatorReal");
            var clonedLeftAndRightSeparatorSelectValuesCollection = _sortableWidgetElement.find(".ClonedLeftAndRightSeparatorSelectValuesDisplay");

            var clonedComponentSeparatorCollection = _sortableWidgetElement.find(".ClonedComponentSeparator");

            var clonedLeftColumnTextboxCollectionLength = clonedLeftColumnTextboxCollection.length;
            for (var i = 0; i < clonedLeftColumnTextboxCollectionLength; i++) {
                var leftColumnStrReal = clonedLeftColumnTextboxCollection.eq(i).val();     // str
                var leftColumnStrDisplay = clonedLeftColumnTextboxCollection.eq(i).val();     // str
                if (_leftColumnAttributes.enableEscapedSymbol) leftColumnStrReal = replaceWithEscapedSymbol(leftColumnStrReal, _leftColumnAttributes.enableEscapedSymbolButNoEscapedForField);

                var leftAndRightSeparatorLabelDisplay = clonedLeftAndRightSeparatorLabelDisplayCollection.eq(i).text();     // str
                var leftAndRightSeparatorLabelReal = clonedLeftAndRightSeparatorLabelRealCollection.eq(i).text();   // str
                var leftAndRightSeparatorSelectValuesReal = clonedLeftAndRightSeparatorSelectValuesCollection.eq(i).val();  // str
                var leftAndRightSeparatorSelectValuesDisplay = clonedLeftAndRightSeparatorSelectValuesCollection.eq(i).find('option[selected="selected"]').text();  // str

                var rightColumnStrReal = clonedRightColumnTextboxCollection.eq(i).val();    // str
                var rightColumnStrDisplay = clonedRightColumnTextboxCollection.eq(i).val();    // str
                if (_rightColumnAttributes.enableEscapedSymbol) rightColumnStrReal = replaceWithEscapedSymbol(rightColumnStrReal, _rightColumnAttributes.enableEscapedSymbolButNoEscapedForField);

                var componentSeparatorStrReal = clonedComponentSeparatorCollection.eq(i).val(); // str
                var componentSeparatorStrDisplay = clonedComponentSeparatorCollection.eq(i).val(); // str
                if (_componentSeparatorColumnAttributes.displayStr !== "") componentSeparatorStrDisplay = _componentSeparatorColumnAttributes.displayStr;   // modify the display str

                if (i === clonedLeftColumnTextboxCollectionLength - 1) {
                    // if this is the last component
                    if (clonedRightColumnTextboxCollection.eq(i).is(':visible')) {
                        if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) {
                            mappingStrReal = mappingStrReal + (leftColumnStrReal + leftAndRightSeparatorSelectValuesReal + rightColumnStrReal);
                        } else {
                            // if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.labelDisplay.toString())
                            mappingStrReal = mappingStrReal + (leftColumnStrReal + _leftAndRightSeparatorAttributes.strReal + rightColumnStrReal);
                        }
                    } else {
                        mappingStrReal = mappingStrReal + (leftColumnStrReal);
                    }
                } else {
                    // if this is NOT the last component
                    if (clonedRightColumnTextboxCollection.eq(i).is(':visible')) {
                        if (_leftAndRightSeparatorAttributes.leftAndRightSeparatorType == columnTypeEnum().columnType.selectDropdown.toString()) {
                            mappingStrReal = mappingStrReal + (leftColumnStrReal + leftAndRightSeparatorSelectValuesReal + rightColumnStrReal + componentSeparatorStrReal);
                        } else {
                            mappingStrReal = mappingStrReal + (leftColumnStrReal + _leftAndRightSeparatorAttributes.strReal + rightColumnStrReal + componentSeparatorStrReal);
                        }
                    } else {
                        mappingStrReal = mappingStrReal + (leftColumnStrReal + componentSeparatorStrReal);
                    }
                }
            }

            // Set the mappingStr on screen
            mappingStrDisplay = convertMappingStrRealToMappingStrDisplay(mappingStrReal);
            addCssToComponentSeparator(mappingStrDisplay);
            _columnMappingStrFieldRealElement.html(mappingStrReal);

            _columnMappingEditBtnElement.show(); // Show the Edit Btn
            _columnMappingWidgetElement.hide(); // hide the ColumnMappingWidget
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.show(); // show the .ColumnMappingStrFieldDisplay    
            hideColumnMappingHeaderLabelText(); // hide the header label in ColumnMappingHeaderLabel element.

            _afterCommit(event, mappingStrDisplay, mappingStrReal);   // after commit btn click event
        }; // End of    commitBtnClickHandler(event)  // End of   var commitBtnClickHandler = function (event)


        /// <summary>
        ///     Clear btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var clearBtnClickHandler = function (event) {
            _beforeClearComponent(event);   // before clear btn click event
            privateClearAllComponent();
            _afterClearComponent(event);    // after clear btn click event
        };  // End of   clearBtnClickHandler(event)  // End of   var clearBtnClickHandler = function (event) {


        /// <summary>
        ///     Cancel btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var cancelBtnClickHandler = function (event) {
            _beforeCancel(event);   // before cancel btn click event
            // privateClearAllComponent();
            _columnMappingEditBtnElement.show();
            _columnMappingWidgetElement.hide(); // hide the ColumnMappingWidget
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.show(); // show the .ColumnMappingStrFieldDisplay    
            hideColumnMappingHeaderLabelText(); // hide the header label in ColumnMappingHeaderLabel element.
            _afterCancel(event);    // after cancel btn click event
        }; // End of     function cancelBtnClickHandler(event)    // End of   var cancelBtnClickHandler = function(event) {
        // --------------------------------------------------- End of    Btn Handler ---------------------------------------------------


        // ------------------------------------ Begin of    createMappingStrFactory Method ------------------------------------
        // *******************************************************************************
        /// <summary>
        ///     Create mappingStrFactory
        /// </summary>
        /// <returns>this object</returns>
        this.createMappingStrFactory = function () {
            // hide the ColumnMappingWidget  before press Edit Button
            _columnMappingWidgetElement.hide();
            // Make Sortable 
            makeSortableWidget();

            // Set "Edit", "Add", "Commit", "Clear", "Cancel" Btn click event handler
            _columnMappingEditBtnElement.on("click", editBtnClickHandler);    // (Set the "Edit" Btn) Register the editBtnClickHandler Event 
            _sortableWidgetAddBtnElement.on("click", addBtnClickHandler);   // (Set the "Add" Btn) Register the addBtnClickHandler Click Event  
            _sortableWidgetCommitBtnElement.on("click", commitBtnClickHandler); // (Set the "Commit" Btn) Register the commitBtnClickHandler Event  
            _sortableWidgetClearBtnElement.on("click", clearBtnClickHandler);   // (Set the "Clear" Btn) Register the clearBtnClickHandler Event  
            _sortableWidgetCancelBtnElement.on("click", cancelBtnClickHandler);  // (Set the "Cancel" Btn) Register the cancelBtnClickHandler Event 

            // add tips for "Edit", "Add", "Commit", "Clear", "Cancel" Btn
            //addTooltip(_columnMappingEditBtnElement, _editBtnTipStr);    // Edit Btn jquery ui tool tip
            //addTooltip(_sortableWidgetAddBtnElement, _addBtnTipStr);    // Add Btn jquery ui tool tip
            //addTooltip(_sortableWidgetCommitBtnElement, _commitBtnTipStr);    // Commit Btn jquery ui tool tip
            //addTooltip(_sortableWidgetClearBtnElement, _clearBtnTipStr);    // Clear Btn jquery ui tool tip
            //addTooltip(_sortableWidgetCancelBtnElement, _cancelBtnTipStr);    // Cancel jquery ui tool tip
            _columnMappingEditBtnElement.attr("title", _editBtnTipStr);  // Edit Btn tip
            _sortableWidgetAddBtnElement.attr("title", _addBtnTipStr);  // Add Btn tip
            _sortableWidgetCommitBtnElement.attr("title", _commitBtnTipStr);  // Commit Btn tip
            _sortableWidgetClearBtnElement.attr("title", _clearBtnTipStr);  // Clear Btn tip
            _sortableWidgetCancelBtnElement.attr("title", _cancelBtnTipStr);  // Cancel Btn tip

            // set leftAndRightSeparatorStrReal   and   leftAndRightSeparatorStrDisplay in html
            _leftAndRightSeparatorDisplayElement = _leftAndRightSeparatorDisplayElement.html(_leftAndRightSeparatorAttributes.strDisplay);
            _leftAndRightSeparatorRealElement = _leftAndRightSeparatorRealElement.html(_leftAndRightSeparatorAttributes.strReal);

            // set componentSeparatorStrDisplay in html
            _componentSeparatorDisplayElement = _componentSeparatorDisplayElement.html(_componentSeparatorColumnAttributes.displayStr);

            // Convert mappingStrReal to mappingStrDisplay   and show  .ColumnMappingStrFieldDisplay
            convertMappingStrRealToMappingStrDisplayWithCss(_mappingStr);

            // get the mapping str parameter from user and put into .ColumnMappingStrFieldReal.
            // then deserialise into component.
            _columnMappingStrFieldRealElement.html(_mappingStr);   // write the mappingStrReal to ColumnMappingStrFieldReal // E.g. DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21+Protocol=LDAP   
            privateDeserializeMappingStrToComponent(_columnMappingStrFieldRealElement.html()); // deserialize .ColumnMappingStrFieldReal to component.

            setColumnMappingHeaderLabelText();  //  Set the html text to header label in ColumnMappingHeaderLabel element
            hideColumnMappingHeaderLabelText(); //  hide the header label in ColumnMappingHeaderLabel element

            // Hide or Show the main buttons whcih includes "Add button", "Commit button", "Clear button", "Cancel button"
            hideOrShowMainBtns();

            return this;
        } // End of    this.createMappingStrFactory()      // End of   this.createMappingStrFactory = function() 

        this.construct(elementID, mappingStr, isAlwaysShownColumnMappingStrFieldDisplay, sortableWidgetWidth, leftColumnHeaderLabelStrDisplay, leftAndRightSeparatorHeaderLabelStrDisplay, rightColumnHeaderLabelStrDisplay, componentSeparatorHeaderLabelStrDisplay, isShowedLeftColumnHeaderLabelStrDisplay, isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, isShowedRightColumnHeaderLabelStrDisplay, isShowedComponentSeparatorHeaderLabelStrDisplay, componentSeparatorStyle, leftColumnDataArr, rightColumnDataArr, lastComponentSeparatorDefaultValue, isShowedComponentSeparator, componentSeparatorDataArr, componentSeparatorStrDisplay, isShowedleftAndRightSeparator, leftAndRightSeparatorType, leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, leftAndRightSeparatorStrDisplay, leftAndRightSeparatorStrReal, leftAndRightSeparatorIndexOfSelectDefaultValue, leftAndRightSeparatorSelectValuesRealArr, leftAndRightSeparatorselectValuesDisplayArr, leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, escapedSymbolsArr, dragBtnTipStr, isShowedRemoveBtn, removeBtnTipStr, editBtnTipStr, isShowedLeftColumnTextboxDisplay, isShowedLeftColumnTextbox, leftColumnType, isShowedRightColumnTextboxDisplay, isShowedRightColumnTextbox, rightColumnType, componentSeparatorColumnType, beforeEdit, afterEdit, isShowedAddBtn, addBtnTipStr, beforeAddComponent, afterAddComponent, isShowedCommitBtn, commitBtnTipStr, beforeCommit, afterCommit, isShowedClearBtn, clearBtnTipStr, beforeClearComponent, afterClearComponent, isShowedCancelBtn, cancelBtnTipStr, beforeCancel, afterCancel);       ////// adding more parameter here
    }; // End of   function mappingStrFactory
    // ================================================== Begin of    mappingStrFactory ==================================================























    // ================================================== Begin of   joinMappingStrGenerator jQuery Plugin ==================================================
    // ======================= Begin of     joinMappingWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access mappingStrFactory.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value for mappingStrFactory</param>
    var joinMappingWidgetAgent = function (element, options) {
        var emptyFunction = function () { };
        var _element = element;
        var _defaults = {
            className: "joinMappingStrGenerator",
            columnMappingStr: "",
            isAlwaysShownColumnMappingStrFieldDisplay: false,
            sortableWidgetWidth: "800px",
            leftColumnHeaderLabelStrDisplay: '',
            leftAndRightSeparatorHeaderLabelStrDisplay: '',
            rightColumnHeaderLabelStrDisplay: '',
            componentSeparatorHeaderLabelStrDisplay: '',
            isShowedLeftColumnHeaderLabelStrDisplay: false,
            isShowedLeftAndRightSeparatorHeaderLabelStrDisplay: false,
            isShowedRightColumnHeaderLabelStrDisplay: false,
            isShowedComponentSeparatorHeaderLabelStrDisplay: false,
            componentSeparatorStyle: {},   // componentSeparatorStyle: { "font-weight": "bold", "color": "blue", "font-size": "20px" },
            leftColumnDataArr: [],   // the left column available value // E.g. leftColumnDataArr:["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
            rightColumnDataArr: [], // the right column available value   // rightColumnDataArr: ["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
            indexOfLastComponentSeparatorDefaultValue: 0,  // index of last component separator default value.  E.g. if componentSeparatorDataArr: [",", "+"], then 0 means ","
            isShowedComponentSeparator: false,
            componentSeparatorDataArr: [";;"],
            componentSeparatorStrDisplay: '<br/>',
            isShowedleftAndRightSeparator: true,
            leftAndRightSeparatorType: columnTypeEnum().columnType.labelDisplay.toString(),
            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '<span style="color: blue;font-weight:bold;font-size:20px"> join on </span> ',
            leftAndRightSeparatorStrDisplay: " join on ",
            leftAndRightSeparatorStrReal: "::",
            leftAndRightSeparatorIndexOfSelectDefaultValue: 0,
            leftAndRightSeparatorSelectValuesRealArr: [],
            leftAndRightSeparatorselectValuesDisplayArr: [],
            leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay: [],
            escapedSymbolsArr: [], // ["+", "=", ",", "[", "]", "@"],  // when meet this symbol, then add escaped symbol "\" in the front.
            dragBtnTipStr: "Click and drag.",
            isShowedRemoveBtn: true,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the column mapping.",
            isShowedLeftColumnTextboxDisplay: false,
            isShowedLeftColumnTextbox: true,
            leftColumnType: columnTypeEnum().columnType.editableDropdownValidValue.toString(), // "editableDropdownValidValue",  
            isShowedRightColumnTextboxDisplay: false,
            isShowedRightColumnTextbox: true,
            rightColumnType: columnTypeEnum().columnType.editableDropdownValidValue.toString(),  // "editableDropdownValidValue",     
            componentSeparatorColumnType: columnTypeEnum().columnType.joinMappingComponentSeparatorColumn.toString(),     // "joinMappingComponentSeparatorColumn",  
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            isShowedAddBtn: true,
            addBtnTipStr: "Add a new column mapping component.",
            beforeAddComponent: emptyFunction,
            afterAddComponent: emptyFunction,
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current column mapping configuration.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction, // _afterCommit(event, mappingStrDisplay, mappingStrReal)
            isShowedClearBtn: true,
            clearBtnTipStr: "Clear the column mapping components.",
            beforeClearComponent: emptyFunction,
            afterClearComponent: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel editing the column mapping.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something.

        if (!((document.documentMode || 100) < 9)) {
            // IE9+ and others
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is a unique string, and also no sub string to each other.
            if (!((new strSpecialRuleHelper()).isUniqueStrArrayAndNoSubStrToEachOther([_config.leftAndRightSeparatorStrReal.toString()], _config.componentSeparatorDataArr, false)._isUniqueStrArrayAndNoSubStrToEachOther)) alert("inputParameterError:  leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is not an unique string, or no sub string to each other. \n" + " SourceClass : " + _config.className);
            if (!IsAllItemsLengthAreEqual([_config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay])) alert('joinMappingStrGenerator Error message:   leftAndRightSeparatorSelectValuesRealArr.length  and  leftAndRightSeparatorselectValuesDisplayArr.length  and  leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay.length  must be the same.');
        }

        // create new mappingStrFactory
        var _myMappingStrFactory = (new mappingStrFactory(_element.attr("id"), _config.columnMappingStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.sortableWidgetWidth, _config.leftColumnHeaderLabelStrDisplay, _config.leftAndRightSeparatorHeaderLabelStrDisplay, _config.rightColumnHeaderLabelStrDisplay, _config.componentSeparatorHeaderLabelStrDisplay, _config.isShowedLeftColumnHeaderLabelStrDisplay, _config.isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, _config.isShowedRightColumnHeaderLabelStrDisplay, _config.isShowedComponentSeparatorHeaderLabelStrDisplay, _config.componentSeparatorStyle, _config.leftColumnDataArr, _config.rightColumnDataArr, _config.componentSeparatorDataArr[_config.indexOfLastComponentSeparatorDefaultValue], _config.isShowedComponentSeparator, _config.componentSeparatorDataArr, _config.componentSeparatorStrDisplay, _config.isShowedleftAndRightSeparator, _config.leftAndRightSeparatorType, _config.leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, _config.leftAndRightSeparatorStrDisplay, _config.leftAndRightSeparatorStrReal, _config.leftAndRightSeparatorIndexOfSelectDefaultValue, _config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, _config.escapedSymbolsArr, _config.dragBtnTipStr, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextboxDisplay, _config.isShowedLeftColumnTextbox, _config.leftColumnType, _config.isShowedRightColumnTextboxDisplay, _config.isShowedRightColumnTextbox, _config.rightColumnType, _config.componentSeparatorColumnType, _config.beforeEdit, _config.afterEdit, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeAddComponent, _config.afterAddComponent, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeClearComponent, _config.afterClearComponent, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.beforeCancel, _config.afterCancel)).createMappingStrFactory();       ////// adding more parameter here
    };  // End of   var joinMappingWidgetAgent = function (element, options)
    // ======================= Begin of     joinMappingWidgetAgent =======================


    // ======================= Begin of     joinMappingStrGenerator =======================
    /// <summary>
    ///     mappingStrGenerator 
    /// </summary>
    $.fn.joinMappingStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            // if the element hasn't had the plugin, then create the plugin, use joinMappingWidgetAgent to get mappingStrFactory
            if (!element.data("joinMappingStrGenerator")) element.data("joinMappingStrGenerator", (new joinMappingWidgetAgent(element, options)));
        }); // End of   this.each(function () {
    };  // End of   $.fn.joinMappingStrGenerator = function (options)
    // ======================= End of     joinMappingStrGenerator =======================
    // ================================================== Begin of   joinMappingStrGenerator jQuery Plugin ==================================================

















    // ================================================== Begin of   copyToMappingStrGenerator jQuery Plugin ==================================================
    // ======================= Begin of     copyToMappingWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access mappingStrFactory.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value for mappingStrFactory</param>
    var copyToMappingWidgetAgent = function (element, options) {
        var emptyFunction = function () { };
        var _element = element;
        var _defaults = {
            className: "copyToMappingStrGenerator",
            columnMappingStr: "",
            isAlwaysShownColumnMappingStrFieldDisplay: false,
            sortableWidgetWidth: "800px",
            leftColumnHeaderLabelStrDisplay: '',
            leftAndRightSeparatorHeaderLabelStrDisplay: '',
            rightColumnHeaderLabelStrDisplay: '',
            componentSeparatorHeaderLabelStrDisplay: '',
            isShowedLeftColumnHeaderLabelStrDisplay: false,
            isShowedLeftAndRightSeparatorHeaderLabelStrDisplay: false,
            isShowedRightColumnHeaderLabelStrDisplay: false,
            isShowedComponentSeparatorHeaderLabelStrDisplay: false,
            componentSeparatorStyle: {},   // componentSeparatorStyle: { "font-weight": "bold", "color": "blue", "font-size": "20px" },
            leftColumnDataArr: [],   // the left column available value // E.g. leftColumnDataArr:["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
            rightColumnDataArr: [], // the right column available value
            indexOfLastComponentSeparatorDefaultValue: 0,  // index of last component separator default value.  E.g. if componentSeparatorDataArr: [",", "+"], then 0 means ","
            isShowedComponentSeparator: false,
            componentSeparatorDataArr: [";;"],
            componentSeparatorStrDisplay: '<br/>',
            isShowedleftAndRightSeparator: true,
            leftAndRightSeparatorType: columnTypeEnum().columnType.labelDisplay.toString(),
            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '<span style="color: blue;font-weight:bold;font-size:20px"> insert to </span> ',
            leftAndRightSeparatorStrDisplay: " insert to ",
            leftAndRightSeparatorStrReal: "::",
            leftAndRightSeparatorIndexOfSelectDefaultValue: 0,
            leftAndRightSeparatorSelectValuesRealArr: [],
            leftAndRightSeparatorselectValuesDisplayArr: [],
            leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay: [],
            escapedSymbolsArr: [], // ["+", "=", ",", "[", "]", "@"],  // when meet this symbol, then add escaped symbol "\" in the front.
            dragBtnTipStr: "Click and drag.",
            isShowedRemoveBtn: true,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the column mapping.",
            isShowedLeftColumnTextboxDisplay: false,
            isShowedLeftColumnTextbox: true,
            leftColumnType: columnTypeEnum().columnType.editableDropdownValidValueCopyToOther.toString(), // "editableDropdownValidValueCopyToOther",   
            isShowedRightColumnTextboxDisplay: false,
            isShowedRightColumnTextbox: true,
            rightColumnType: columnTypeEnum().columnType.textbox.toString(),  // "textbox",     
            componentSeparatorColumnType: columnTypeEnum().columnType.copyToMappingComponentSeparatorColumn.toString(),     // "copyToMappingComponentSeparatorColumn",  
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            isShowedAddBtn: true,
            addBtnTipStr: "Add a new column mapping component.",
            beforeAddComponent: emptyFunction,
            afterAddComponent: emptyFunction,
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current column mapping configuration.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction, // _afterCommit(event, mappingStrDisplay, mappingStrReal)
            isShowedClearBtn: true,
            clearBtnTipStr: "Clear the column mapping components.",
            beforeClearComponent: emptyFunction,
            afterClearComponent: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel editing the column mapping.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something.
        if (!((document.documentMode || 100) < 9)) {
            // IE9+ and others
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is a unique string, and also no sub string to each other.
            if (!((new strSpecialRuleHelper()).isUniqueStrArrayAndNoSubStrToEachOther([_config.leftAndRightSeparatorStrReal.toString()], _config.componentSeparatorDataArr, false)._isUniqueStrArrayAndNoSubStrToEachOther)) alert("inputParameterError:  leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is not an unique string, or no sub string to each other. \n" + " SourceClass : " + _config.className);
            if (!IsAllItemsLengthAreEqual([_config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay])) alert('copyToMappingStrGenerator Error message:   leftAndRightSeparatorSelectValuesRealArr.length  and  leftAndRightSeparatorselectValuesDisplayArr.length  and  leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay.length  must be the same.');
        }

        // create new mappingStrFactory
        var _myMappingStrFactory = (new mappingStrFactory(_element.attr("id"), _config.columnMappingStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.sortableWidgetWidth, _config.leftColumnHeaderLabelStrDisplay, _config.leftAndRightSeparatorHeaderLabelStrDisplay, _config.rightColumnHeaderLabelStrDisplay, _config.componentSeparatorHeaderLabelStrDisplay, _config.isShowedLeftColumnHeaderLabelStrDisplay, _config.isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, _config.isShowedRightColumnHeaderLabelStrDisplay, _config.isShowedComponentSeparatorHeaderLabelStrDisplay, _config.componentSeparatorStyle, _config.leftColumnDataArr, _config.rightColumnDataArr, _config.componentSeparatorDataArr[_config.indexOfLastComponentSeparatorDefaultValue], _config.isShowedComponentSeparator, _config.componentSeparatorDataArr, _config.componentSeparatorStrDisplay, _config.isShowedleftAndRightSeparator, _config.leftAndRightSeparatorType, _config.leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, _config.leftAndRightSeparatorStrDisplay, _config.leftAndRightSeparatorStrReal, _config.leftAndRightSeparatorIndexOfSelectDefaultValue, _config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, _config.escapedSymbolsArr, _config.dragBtnTipStr, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextboxDisplay, _config.isShowedLeftColumnTextbox, _config.leftColumnType, _config.isShowedRightColumnTextboxDisplay, _config.isShowedRightColumnTextbox, _config.rightColumnType, _config.componentSeparatorColumnType, _config.beforeEdit, _config.afterEdit, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeAddComponent, _config.afterAddComponent, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeClearComponent, _config.afterClearComponent, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.beforeCancel, _config.afterCancel)).createMappingStrFactory();   ////// adding more parameter here
    };  // End of   var copyToMappingWidgetAgent = function (element, options)
    // ======================= Begin of     copyToMappingWidgetAgent =======================


    // ======================= Begin of     copyToMappingStrGenerator =======================
    /// <summary>
    ///     mappingStrGenerator 
    /// </summary>
    $.fn.copyToMappingStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            // if the element hasn't had the plugin, then create the plugin, use copyToMappingWidgetAgent to get mappingStrFactory
            if (!element.data("copyToMappingStrGenerator")) element.data("copyToMappingStrGenerator", (new copyToMappingWidgetAgent(element, options)));
        }); // End of   this.each(function () {
    };  // End of   $.fn.copyToMappingStrGenerator = function (options)
    // ======================= End of     copyToMappingStrGenerator =======================
    // ================================================== Begin of   copyToMappingStrGenerator jQuery Plugin ==================================================









    // ================================================== Begin of   searchForMappingStrGenerator jQuery Plugin ==================================================
    // ======================= Begin of     searchForMappingWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access mappingStrFactory.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value for mappingStrFactory</param>
    var searchForMappingWidgetAgent = function (element, options) {
        var emptyFunction = function () { };
        var _element = element;
        var _defaults = {
            className: "searchForMappingStrGenerator",
            columnMappingStr: "",
            isAlwaysShownColumnMappingStrFieldDisplay: false,
            sortableWidgetWidth: "800px",
            leftColumnHeaderLabelStrDisplay: '',
            leftAndRightSeparatorHeaderLabelStrDisplay: '',
            rightColumnHeaderLabelStrDisplay: '',
            componentSeparatorHeaderLabelStrDisplay: '',
            isShowedLeftColumnHeaderLabelStrDisplay: false,
            isShowedLeftAndRightSeparatorHeaderLabelStrDisplay: false,
            isShowedRightColumnHeaderLabelStrDisplay: false,
            isShowedComponentSeparatorHeaderLabelStrDisplay: false,
            componentSeparatorStyle: {},   // componentSeparatorStyle: { "font-weight": "bold", "color": "blue", "font-size": "20px" },
            leftColumnDataArr: [],   // the left column available value // E.g. leftColumnDataArr:["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
            rightColumnDataArr: [], // the right column available value
            indexOfLastComponentSeparatorDefaultValue: 0,  // index of last component separator default value.  E.g. if componentSeparatorDataArr: [",", "+"], then 0 means ","
            isShowedComponentSeparator: false,
            componentSeparatorDataArr: [";;"],
            componentSeparatorStrDisplay: '<br/>',
            isShowedleftAndRightSeparator: true,
            leftAndRightSeparatorType: columnTypeEnum().columnType.labelDisplay.toString(),
            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '<span style="color: blue;font-weight:bold;font-size:20px"> search for </span> ',
            leftAndRightSeparatorStrDisplay: " search for ",
            leftAndRightSeparatorStrReal: "::",
            leftAndRightSeparatorIndexOfSelectDefaultValue: 0,
            leftAndRightSeparatorSelectValuesRealArr: [],
            leftAndRightSeparatorselectValuesDisplayArr: [],
            leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay: [],
            escapedSymbolsArr: [], // ["+", "=", ",", "[", "]", "@"],  // when meet this symbol, then add escaped symbol "\" in the front.
            dragBtnTipStr: "Click and drag.",
            isShowedRemoveBtn: true,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the column mapping.",
            isShowedLeftColumnTextboxDisplay: false,
            isShowedLeftColumnTextbox: true,
            leftColumnType: columnTypeEnum().columnType.editableDropdownValidValue.toString(), // "editableDropdownValidValue",  
            isShowedRightColumnTextboxDisplay: false,
            isShowedRightColumnTextbox: true,
            rightColumnType: columnTypeEnum().columnType.textbox.toString(),  // "textbox",     
            componentSeparatorColumnType: columnTypeEnum().columnType.searchForMappingComponentSeparatorColumn.toString(),     // "searchForMappingComponentSeparatorColumn",  
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            isShowedAddBtn: true,
            addBtnTipStr: "Add a new column mapping component.",
            beforeAddComponent: emptyFunction,
            afterAddComponent: emptyFunction,
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current column mapping configuration.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction, // _afterCommit(event, mappingStrDisplay, mappingStrReal)
            isShowedClearBtn: true,
            clearBtnTipStr: "Clear the column mapping components.",
            beforeClearComponent: emptyFunction,
            afterClearComponent: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel editing the column mapping.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something.
        if (!((document.documentMode || 100) < 9)) {
            // IE9+ and others
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is a unique string, and also no sub string to each other.
            if (!((new strSpecialRuleHelper()).isUniqueStrArrayAndNoSubStrToEachOther([_config.leftAndRightSeparatorStrReal.toString()], _config.componentSeparatorDataArr, false)._isUniqueStrArrayAndNoSubStrToEachOther)) alert("inputParameterError:  leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is not an unique string, or no sub string to each other. \n" + " SourceClass : " + _config.className);
            if (!IsAllItemsLengthAreEqual([_config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay])) alert('searchForMappingStrGenerator Error message:   leftAndRightSeparatorSelectValuesRealArr.length  and  leftAndRightSeparatorselectValuesDisplayArr.length  and  leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay.length  must be the same.');
        }

        // create new mappingStrFactory
        var _myMappingStrFactory = (new mappingStrFactory(_element.attr("id"), _config.columnMappingStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.sortableWidgetWidth, _config.leftColumnHeaderLabelStrDisplay, _config.leftAndRightSeparatorHeaderLabelStrDisplay, _config.rightColumnHeaderLabelStrDisplay, _config.componentSeparatorHeaderLabelStrDisplay, _config.isShowedLeftColumnHeaderLabelStrDisplay, _config.isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, _config.isShowedRightColumnHeaderLabelStrDisplay, _config.isShowedComponentSeparatorHeaderLabelStrDisplay, _config.componentSeparatorStyle, _config.leftColumnDataArr, _config.rightColumnDataArr, _config.componentSeparatorDataArr[_config.indexOfLastComponentSeparatorDefaultValue], _config.isShowedComponentSeparator, _config.componentSeparatorDataArr, _config.componentSeparatorStrDisplay, _config.isShowedleftAndRightSeparator, _config.leftAndRightSeparatorType, _config.leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, _config.leftAndRightSeparatorStrDisplay, _config.leftAndRightSeparatorStrReal, _config.leftAndRightSeparatorIndexOfSelectDefaultValue, _config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, _config.escapedSymbolsArr, _config.dragBtnTipStr, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextboxDisplay, _config.isShowedLeftColumnTextbox, _config.leftColumnType, _config.isShowedRightColumnTextboxDisplay, _config.isShowedRightColumnTextbox, _config.rightColumnType, _config.componentSeparatorColumnType, _config.beforeEdit, _config.afterEdit, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeAddComponent, _config.afterAddComponent, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeClearComponent, _config.afterClearComponent, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.beforeCancel, _config.afterCancel)).createMappingStrFactory();    ////// adding more parameter here
    };  // End of   var searchForMappingWidgetAgent = function (element, options)
    // ======================= Begin of     searchForMappingWidgetAgent =======================


    // ======================= Begin of     searchForMappingStrGenerator =======================
    /// <summary>
    ///     mappingStrGenerator 
    /// </summary>
    $.fn.searchForMappingStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            // if the element hasn't had the plugin, then create the plugin, use searchForMappingWidgetAgent to get mappingStrFactory
            if (!element.data("searchForMappingStrGenerator")) element.data("searchForMappingStrGenerator", (new searchForMappingWidgetAgent(element, options)));
        }); // End of   this.each(function () {
    };  // End of   $.fn.searchForMappingStrGenerator = function (options)
    // ======================= End of     searchForMappingStrGenerator =======================
    // ================================================== Begin of   searchForMappingStrGenerator jQuery Plugin ==================================================















    // ================================================== Begin of   dnStrGenerator jQuery Plugin ==================================================
    // ======================= Begin of     dnStrWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access mappingStrFactory.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value for mappingStrFactory</param>
    var dnStrWidgetAgent = function (element, options) {
        var emptyFunction = function () { };
        var _element = element;
        var _defaults = {
            className: "dnStrGenerator",
            dnStr: "",
            isAlwaysShownColumnMappingStrFieldDisplay: true,
            sortableWidgetWidth: "581px",   // for dnStrGenerator, the max width is 581px for  deserializeMappingStrToComponent .
            leftColumnHeaderLabelStrDisplay: '',
            leftAndRightSeparatorHeaderLabelStrDisplay: '',
            rightColumnHeaderLabelStrDisplay: '',
            componentSeparatorHeaderLabelStrDisplay: '',
            isShowedLeftColumnHeaderLabelStrDisplay: false,
            isShowedLeftAndRightSeparatorHeaderLabelStrDisplay: false,
            isShowedRightColumnHeaderLabelStrDisplay: false,
            isShowedComponentSeparatorHeaderLabelStrDisplay: false,
            componentSeparatorStyle: { "font-weight": "bold", "color": "blue", "font-size": "20px", "margin-right": "10px", "margin-left": "10px" },
            leftColumnDataArr: ["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],   // the DNHeader available value
            rightColumnDataArr: [], // the DNValue available value
            indexOfLastComponentSeparatorDefaultValue: 0,  // index of last component separator default value.  E.g. if componentSeparatorDataArr: [",", "+"], then 0 means ","
            isShowedComponentSeparator: true,
            componentSeparatorDataArr: [",", "+"],
            componentSeparatorStrDisplay: "",
            isShowedleftAndRightSeparator: true,
            leftAndRightSeparatorType: columnTypeEnum().columnType.labelDisplay.toString(),
            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: "=",
            leftAndRightSeparatorStrDisplay: "=",
            leftAndRightSeparatorStrReal: "=",
            leftAndRightSeparatorIndexOfSelectDefaultValue: 0,
            leftAndRightSeparatorSelectValuesRealArr: [],
            leftAndRightSeparatorselectValuesDisplayArr: [],
            leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay: [],
            escapedSymbolsArr: ["+", "=", ",", "[", "]", "@"],  // when meet this symbol, then add escaped symbol "\" in the front.
            dragBtnTipStr: "Click and drag.",
            isShowedRemoveBtn: true,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the distinguished name.",
            isShowedLeftColumnTextboxDisplay: false,
            isShowedLeftColumnTextbox: true,
            leftColumnType: columnTypeEnum().columnType.dnHeaderColumnEditableDropdown.toString(), // "dnHeaderColumnEditableDropdown",  
            isShowedRightColumnTextboxDisplay: false,
            isShowedRightColumnTextbox: true,
            rightColumnType: columnTypeEnum().columnType.dnValueColumnEditableDropdown.toString(),  // "dnValueColumnEditableDropdown",     
            componentSeparatorColumnType: columnTypeEnum().columnType.dnComponentSeparatorColumn.toString(),     // "dnComponentSeparatorColumn",  
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            isShowedAddBtn: true,
            addBtnTipStr: "Add a new distinguished name component.",
            beforeAddComponent: emptyFunction,
            afterAddComponent: emptyFunction,
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current distinguished name configuration.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction,     // _afterCommit(event, mappingStrDisplay, mappingStrReal)
            isShowedClearBtn: true,
            clearBtnTipStr: "Clear the distinguished name components.",
            beforeClearComponent: emptyFunction,
            afterClearComponent: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel editing the distinguished name.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something.
        if (!((document.documentMode || 100) < 9)) {
            // IE9+ and others
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if    indexOfLastComponentSeparatorDefaultValue  >  (componentSeparatorDataArr.length - 1)  
            if (_config.indexOfLastComponentSeparatorDefaultValue > (_config.componentSeparatorDataArr.length - 1)) alert("OutOfIndexError:  indexOfLastComponentSeparatorDefaultValue === " + _config.indexOfLastComponentSeparatorDefaultValue + " . (componentSeparatorDataArr.length - 1) === " + (_config.componentSeparatorDataArr.length - 1));
            // check if leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is a unique string, and also no sub string to each other.
            if (!((new strSpecialRuleHelper()).isUniqueStrArrayAndNoSubStrToEachOther([_config.leftAndRightSeparatorStrReal.toString()], _config.componentSeparatorDataArr, false)._isUniqueStrArrayAndNoSubStrToEachOther)) alert("inputParameterError:  leftAndRightSeparatorStrReal combine  componentSeparatorDataArr   is not an unique string, or no sub string to each other. \n" + " SourceClass : " + _config.className);
            if (!IsAllItemsLengthAreEqual([_config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay])) alert('dnStrGenerator Error message:   leftAndRightSeparatorSelectValuesRealArr.length  and  leftAndRightSeparatorselectValuesDisplayArr.length  and  leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay.length  must be the same.');
        }

        // create new mappingStrFactory
        var _myMappingStrFactory = (new mappingStrFactory(_element.attr("id"), _config.dnStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.sortableWidgetWidth, _config.leftColumnHeaderLabelStrDisplay, _config.leftAndRightSeparatorHeaderLabelStrDisplay, _config.rightColumnHeaderLabelStrDisplay, _config.componentSeparatorHeaderLabelStrDisplay, _config.isShowedLeftColumnHeaderLabelStrDisplay, _config.isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, _config.isShowedRightColumnHeaderLabelStrDisplay, _config.isShowedComponentSeparatorHeaderLabelStrDisplay, _config.componentSeparatorStyle, _config.leftColumnDataArr, _config.rightColumnDataArr, _config.componentSeparatorDataArr[_config.indexOfLastComponentSeparatorDefaultValue], _config.isShowedComponentSeparator, _config.componentSeparatorDataArr, _config.componentSeparatorStrDisplay, _config.isShowedleftAndRightSeparator, _config.leftAndRightSeparatorType, _config.leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, _config.leftAndRightSeparatorStrDisplay, _config.leftAndRightSeparatorStrReal, _config.leftAndRightSeparatorIndexOfSelectDefaultValue, _config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, _config.escapedSymbolsArr, _config.dragBtnTipStr, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextboxDisplay, _config.isShowedLeftColumnTextbox, _config.leftColumnType, _config.isShowedRightColumnTextboxDisplay, _config.isShowedRightColumnTextbox, _config.rightColumnType, _config.componentSeparatorColumnType, _config.beforeEdit, _config.afterEdit, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeAddComponent, _config.afterAddComponent, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeClearComponent, _config.afterClearComponent, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.beforeCancel, _config.afterCancel)).createMappingStrFactory();  ////// adding more parameter here



        /// <summary>
        ///     Get the mappingStrFactory
        /// </summary>
        /// <returns>mappingStrFactory</returns>
        this.getMappingStrFactory = function () {
            return _myMappingStrFactory;
        };  // End of   getMappingStrFactory() // End of   this.getMappingStrFactory = function () 


        /// <summary>
        ///     Get the real DN which is the mappingStrReal
        ///     E.g. Real DN : DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21,Protocol=LDAP
        /// </summary>
        /// <returns>Real DN</returns>
        this.getDNStrReal = function () {
            return _element.find(".ColumnMappingStrField").find(".ColumnMappingStrFieldReal").html();
        };  // End of   getDNStrReal()  // End of   this.getDNStrReal = function() 

        /// <summary>
        ///     Get the Displayed DN which is mappingStrDisplay
        ///     E.g. Display DN : DC=[kevin]+Bob=Kevin,Bob@unify<span style="font-weight: bold; color: blue; font-size: 20px;">&nbsp;&nbsp;,&nbsp;&nbsp;</span>CN=Chris21<span style="font-weight: bold; color: blue; font-size: 20px;">&nbsp;&nbsp;+&nbsp;&nbsp;</span>Protocol=LDAP
        /// </summary>
        /// <returns>Displayed DN</returns>
        this.getDNStrDisplay = function () {
            return _element.find(".ColumnMappingStrField").find(".ColumnMappingStrFieldDisplay").html();
        };  // End of   getDNStrDisplay()   // End of   this.getDNStrDisplay = function ()


        /// <summary>
        ///     void method
        ///     clear all component.
        ///     for each component,  trigger ComponentRemoveBtn click event to remove all item.
        /// </summary>
        this.clearAllComponent = function () {
            _myMappingStrFactory.clearAllComponent();
        };  // End of   clearAllComponent()  // End of   this.clearAllComponent = function() 


        /// <summary>
        ///     void method
        ///     deserialize mapping string to components
        ///     E.g.
        ///     inputMappingStr  ===    DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify+[FieldC],CN=Chris21+@FieldD+Protocol=LDAP
        /// </summary>
        /// <param name="inputMappingStr">input DN string.</param>
        this.deserializeMappingStrToComponent = function (inputMappingStr) {
            _myMappingStrFactory.deserializeMappingStrToComponent(inputMappingStr);
        };  // End of   deserializeMappingStrToComponent(inputMappingStr)  // End of   this.deserializeMappingStrToComponent = function (inputMappingStr) {

    };  // End of   var dnStrWidgetAgent = function (element, options)
    // ======================= End of     dnStrWidgetAgent =======================


    // ======================= Begin of     dnStrGenerator =======================
    /// <summary>
    ///     dnStrGenerator 
    /// </summary>
    $.fn.dnStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            // if the element hasn't had the plugin, then create the plugin, use dnStrWidgetAgent to get mappingStrFactory
            if (!element.data("dnStrGenerator")) element.data("dnStrGenerator", (new dnStrWidgetAgent(element, options)));
        }); // End of   this.each(function () {
    };  // End of   $.fn.dnStrGenerator = function (options)
    // ======================= End of     dnStrGenerator =======================









    // ================================================== Begin of   directionMappingWidgetAgent jQuery Plugin ==================================================
    // ======================= Begin of     directionMappingWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access mappingStrFactory.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value for mappingStrFactory</param>
    var directionMappingWidgetAgent = function (element, options) {
        var emptyFunction = function () { };
        var _element = element;
        var _defaults = {
            className: "directionMappingStrGenerator",
            columnMappingStr: "",
            isAlwaysShownColumnMappingStrFieldDisplay: true,
            sortableWidgetWidth: "850px",

            leftColumnHeaderLabelStrDisplay: '<span style="margin-left:3.5em; font-weight:bold; font-size:1.5em;"> Adapter </span>',
            leftAndRightSeparatorHeaderLabelStrDisplay: '<span style="margin-left:5.5em; font-weight:bold; font-size:1.5em;"> Direction </span>',
            rightColumnHeaderLabelStrDisplay: '<span style="margin-left:3.5em; font-weight:bold; font-size:1.5em;"> Locker </span>',
            componentSeparatorHeaderLabelStrDisplay: '',
            isShowedLeftColumnHeaderLabelStrDisplay: true,
            isShowedLeftAndRightSeparatorHeaderLabelStrDisplay: true,
            isShowedRightColumnHeaderLabelStrDisplay: true,
            isShowedComponentSeparatorHeaderLabelStrDisplay: false,

            componentSeparatorStyle: {},   // componentSeparatorStyle: { "font-weight": "bold", "color": "blue", "font-size": "20px" },
            leftColumnDataArr: [],   // the left column available value // E.g. leftColumnDataArr:["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
            rightColumnDataArr: [], // the right column available value
            indexOfLastComponentSeparatorDefaultValue: 0,  // index of last component separator default value.  E.g. if componentSeparatorDataArr: [",", "+"], then 0 means ","

            isShowedComponentSeparator: false,
            componentSeparatorDataArr: [";;"],
            componentSeparatorStrDisplay: "</br>",

            isShowedleftAndRightSeparator: true,
            leftAndRightSeparatorType: columnTypeEnum().columnType.selectDropdown.toString(),
            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '',  // '<span style="color: blue;font-weight:bold;font-size:14px"> leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay </span>',
            leftAndRightSeparatorStrDisplay: '',    // "leftAndRightSeparatorStrDisplay",
            leftAndRightSeparatorStrReal: '',   // "leftAndRightSeparatorStrReal",
            leftAndRightSeparatorIndexOfSelectDefaultValue: 0,
            leftAndRightSeparatorSelectValuesRealArr: ["::AdapterToLocker::", "::LockerToAdapter::", "::Bidirectional::"],
            leftAndRightSeparatorselectValuesDisplayArr: ["Adapter to Locker", "Locker to Adapter", "Bidirectional"],
            leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay: ['<span style="color: blue;font-weight:bold;font-size:14px"> Adapter to Locker </span>', '<span style="color: blue;font-weight:bold;font-size:14px"> Locker to Adapter </span>', '<span style="color: blue;font-weight:bold;font-size:14px"> Bidirectional </span>'],

            escapedSymbolsArr: [],  // ["+", "=", ",", "[", "]", "@"],  // when meet this symbol, then add escaped symbol "\" in the front.
            dragBtnTipStr: "Click and drag.",
            isShowedRemoveBtn: true,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the column mapping configuration.",
            isShowedLeftColumnTextboxDisplay: false,
            isShowedLeftColumnTextbox: true,
            leftColumnType: columnTypeEnum().columnType.editableDropdownValidValue.toString(), // "editableDropdownValidValue",  
            isShowedRightColumnTextboxDisplay: false,
            isShowedRightColumnTextbox: true,
            rightColumnType: columnTypeEnum().columnType.editableDropdownValidValue.toString(),  // "editableDropdownValidValue",     
            componentSeparatorColumnType: columnTypeEnum().columnType.joinMappingComponentSeparatorColumn.toString(),
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            isShowedAddBtn: true,
            addBtnTipStr: "Add a new mapping component.",
            beforeAddComponent: emptyFunction,
            afterAddComponent: emptyFunction,
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current column mapping configuration.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction,     // _afterCommit(event, mappingStrDisplay, mappingStrReal)
            isShowedClearBtn: true,
            clearBtnTipStr: "Clear the column mapping components.",
            beforeClearComponent: emptyFunction,
            afterClearComponent: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel editing mapping configuration.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something.
        if (!((document.documentMode || 100) < 9)) {
            // IE9+ and others
            if (_config.leftAndRightSeparatorIndexOfSelectDefaultValue > (_config.leftAndRightSeparatorSelectValuesRealArr.length - 1)) alert("OutOfIndexError:  leftAndRightSeparatorIndexOfSelectDefaultValue === " + _config.leftAndRightSeparatorIndexOfSelectDefaultValue + " . (leftAndRightSeparatorSelectValuesRealArr.length - 1) === " + (_config.leftAndRightSeparatorSelectValuesRealArr.length - 1));
            if (_config.leftAndRightSeparatorIndexOfSelectDefaultValue > (_config.leftAndRightSeparatorSelectValuesRealArr.length - 1)) alert("OutOfIndexError:  leftAndRightSeparatorIndexOfSelectDefaultValue === " + _config.leftAndRightSeparatorIndexOfSelectDefaultValue + " . (leftAndRightSeparatorSelectValuesRealArr.length - 1) === " + (_config.leftAndRightSeparatorSelectValuesRealArr.length - 1));
            if (!IsAllItemsLengthAreEqual([_config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay])) alert('directionMappingStrGenerator Error message:   leftAndRightSeparatorSelectValuesRealArr.length  and  leftAndRightSeparatorselectValuesDisplayArr.length  and  leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay.length  must be the same.');
        }

        // create new mappingStrFactory
        var _myMappingStrFactory = (new mappingStrFactory(_element.attr("id"), _config.columnMappingStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.sortableWidgetWidth, _config.leftColumnHeaderLabelStrDisplay, _config.leftAndRightSeparatorHeaderLabelStrDisplay, _config.rightColumnHeaderLabelStrDisplay, _config.componentSeparatorHeaderLabelStrDisplay, _config.isShowedLeftColumnHeaderLabelStrDisplay, _config.isShowedLeftAndRightSeparatorHeaderLabelStrDisplay, _config.isShowedRightColumnHeaderLabelStrDisplay, _config.isShowedComponentSeparatorHeaderLabelStrDisplay, _config.componentSeparatorStyle, _config.leftColumnDataArr, _config.rightColumnDataArr, _config.componentSeparatorDataArr[_config.indexOfLastComponentSeparatorDefaultValue], _config.isShowedComponentSeparator, _config.componentSeparatorDataArr, _config.componentSeparatorStrDisplay, _config.isShowedleftAndRightSeparator, _config.leftAndRightSeparatorType, _config.leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay, _config.leftAndRightSeparatorStrDisplay, _config.leftAndRightSeparatorStrReal, _config.leftAndRightSeparatorIndexOfSelectDefaultValue, _config.leftAndRightSeparatorSelectValuesRealArr, _config.leftAndRightSeparatorselectValuesDisplayArr, _config.leftAndRightSeparatorselectValuesDisplayArrInColumnMappingStrFieldDisplay, _config.escapedSymbolsArr, _config.dragBtnTipStr, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextboxDisplay, _config.isShowedLeftColumnTextbox, _config.leftColumnType, _config.isShowedRightColumnTextboxDisplay, _config.isShowedRightColumnTextbox, _config.rightColumnType, _config.componentSeparatorColumnType, _config.beforeEdit, _config.afterEdit, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeAddComponent, _config.afterAddComponent, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeClearComponent, _config.afterClearComponent, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.beforeCancel, _config.afterCancel)).createMappingStrFactory();    ////// adding more parameter here
    };  // End of   var directionMappingWidgetAgent = function (element, options)
    // ======================= End of     directionMappingWidgetAgent =======================


    // ======================= Begin of     directionMappingStrGenerator =======================
    /// <summary>
    ///     directionMappingStrGenerator 
    /// </summary>
    $.fn.directionMappingStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            // if the element hasn't had the plugin, then create the plugin, use directionMappingWidgetAgent to get mappingStrFactory
            if (!element.data("directionMappingStrGenerator")) element.data("directionMappingStrGenerator", (new directionMappingWidgetAgent(element, options)));
        }); // End of   this.each(function () {
    };  // End of   $.fn.directionMappingStrGenerator = function (options)
    // ======================= End of     directionMappingStrGenerator =======================
    // ================================================== End of   directionMappingStrGenerator jQuery Plugin ==================================================
})(jQuery);




// ================================================== Begin of    testing code ==================================================

//<div id="directionMappingWidgetId"></div>
//<br />
//<br />
//<div id="mappingStrWidgetId"></div>
//<br/>
//<br/>
//<div id="copyToMappingStrWidgetId"></div>
//<br/>
//<br/>
//<div id="searchForMappingStrWidgetId"></div>
//<br/>
//<br/>
//<div id="dnWidgetComboBox"></div>
//<br/>
//<br/>
//<script type="text/javascript">
//    $(function () {
//        $("#directionMappingWidgetId").directionMappingStrGenerator({
//            columnMappingStr: 'lFieldA::AdapterToLocker::rFieldA;;lFieldB::LockerToAdapter::rFieldB;;lFieldC::Bidirectional::rFieldC',
//            leftColumnDataArr: ['lFieldA', 'lFieldB', 'lFieldC', 'lFieldD', 'lFieldE'],
//            rightColumnDataArr: ['rFieldA', 'rFieldB', 'rFieldC', 'rFieldD', 'rFieldE'],
//            afterCommit: function (event, dnDisplayStr, dnRealStr) {
//                // alert("After Commit. Event type : " + event.type + "  ;  dnDisplayStr : " + dnDisplayStr + "  ;  dnRealStr : " + dnRealStr);
//            }
//        });
//        //$("#mappingStrHiddenId").hide();
//        $("#mappingStrWidgetId").joinMappingStrGenerator({
//            columnMappingStr: 'DC::DC1;;BB::BB02',
//            leftColumnDataArr: ['lFieldA', 'lFieldB', 'lFieldC', 'lFieldD', 'lFieldE'],
//            rightColumnDataArr: ['rFieldA', 'rFieldB', 'rFieldC', 'rFieldD', 'rFieldE'],
//            componentSeparatorStrDisplay: '<br/>',
//            leftAndRightSeparatorStrDisplay: ' join on ',
//            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '  <span style="font-weight:bold; color:blue; font-size:14px;"> join on </span> ',
//            afterCommit: function (event, mappingStrDisplay, mappingStrReal) {
//                // $("#mappingStrHiddenId").val(mappingStrReal);
//            }
//        });
//        // $("#mappingStrHiddenId").hide();
//        $("#copyToMappingStrWidgetId").copyToMappingStrGenerator({
//            columnMappingStr: 'DC::DC1;;BB::BB02',
//            leftColumnDataArr: ['lFieldA', 'lFieldB', 'lFieldC', 'lFieldD', 'lFieldE'],
//            componentSeparatorStrDisplay: '<br/>',
//            leftAndRightSeparatorStrDisplay: ' map to ',
//            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '  <span style="font-weight:bold; color:blue; font-size:14px;"> map to </span> ',
//            afterCommit: function (event, mappingStrDisplay, mappingStrReal) {
//                // $("#mappingStrHiddenId").val(mappingStrReal);
//            }
//        });       
//        // $("#mappingStrHiddenId").hide();
//        $("#searchForMappingStrWidgetId").searchForMappingStrGenerator({
//            columnMappingStr: 'DC::DC1;;BB::BB02',
//            leftColumnDataArr: ['lFieldA', 'lFieldB', 'lFieldC', 'lFieldD', 'lFieldE'],
//            componentSeparatorStrDisplay: '<br/>',
//            leftAndRightSeparatorStrDisplay: ' search for ',
//            leftAndRightSeparatorStrDisplayInColumnMappingStrFieldDisplay: '  <span style="font-weight:bold; color:blue; font-size:14px;"> search for </span> ',
//            afterCommit: function (event, mappingStrDisplay, mappingStrReal) {
//                // $("#mappingStrHiddenId").val(mappingStrReal);
//            }
//        });
//        $('#dnWidgetComboBox').dnStrGenerator({
//            dnStr: 'CN=FieldA,DC=rFieldB+L=rFieldC',
//            leftColumnDataArr: ["C", "CN", "DC", "L", "O", "OU", "SECAUTHORITY", "ST", "STREET", "UID"],
//            rightColumnDataArr: ['rFieldA', 'rFieldB', 'rFieldC', 'rFieldD', 'rFieldE'],
//            afterCommit: function (event, mappingStrDisplay, mappingStrReal) {
//                // $("#templateId").val(mappingStrReal);
//            }
//        }); 
//    });
//</script>
// ================================================== End of    testing code ==================================================





// ================================================== Begin of    HTML append ==================================================
//  var _htmlCodeStr =  .....

//<div class="ColumnMappingComboBox">
//    <div class="ColumnMappingStrField toNextLine">
//        <div class="toNextLine" style="display: none;">
//            Display DN String :
//        </div>
//        <div class="ColumnMappingStrFieldDisplay toNextLine">
//            DC=[kevin]+Bob=Kevin,Bob@unify<span style="color: blue; font-size: 20px; font-weight: bold;">&nbsp;+&nbsp;</span>
//            CN=Chris21 <span style="color: blue; font-size: 20px; font-weight: bold;">&nbsp;+&nbsp;</span>
//            Protocol=LDAP
//        </div>
//        <div class="toNextLine" style="display: none;">
//            Real DN String :
//        </div>
//        <div class="ColumnMappingStrFieldReal toNextLine" style="display: none;">
//            DC=\[kevin\]\+Bob\=Kevin\,Bob\@unify,CN=Chris21+Protocol=LDAP
//        </div>
//        <div class="ColumnMappingEditBtn WidgetBtnStyle WidgetBtnTextStyle m-btn">
//            Edit
//        </div>
//    </div>
//    <div class="ColumnMappingHeaderLabel toNextLine">
//        <span class="LeftColumnHeaderLabel LeftColumnHeaderLabelStyle"></span>
//        <span class="LeftAndRightSeparatorHeaderLabel LeftAndRightSeparatorHeaderLabelStyle"></span>
//        <span class="RightColumnHeaderLabel RightColumnHeaderLabelStyle"></span>
//        <span class="ComponentSeparatorHeaderLabel ComponentSeparatorHeaderLabelStyle"></span>
//    </div>
//    <div class="ColumnMappingWidget toNextLine">
//        <div class="SortableWidgetTemplate" style="height: 0px; visibility: hidden; width: 0px;">
//            <div class="SortableWidgetItem SortableWidgetItemStyle ui-state-default" style="width: auto;">
//                <span class="SortableWidgetItemDragBtnPlaceHolder SortableWidgetItemComponentStyle DragBtnStyle">
//                    <span class="SortableWidgetItemDragBtn ui-icon ui-icon-arrowthick-2-n-s"></span>
//                </span>
//                <span class="LeftColumnTextboxPlaceHolder SortableWidgetItemComponentStyle">
//                    <span><span class="LeftColumnTextboxDisplay TextboxDisplayStyle"></span></span>
//                    <span><input class="LeftColumnTextbox TextboxStyle" /></span>
//                    <span>
//                        <a class="LeftColumnDropdownBtn DropdownBtnStyle" href="javascript:;">
//                            <span class="ui-icon ui-icon-triangle-1-s DropdownBtnPicStyle"></span>
//                        </a>
//                    </span>
//                </span>
//                <span class="LeftAndRightSeparatorPlaceHolder SortableWidgetItemComponentStyle">
//                    <span class="LeftAndRightSeparatorDisplay LeftAndRightSeparatorDisplayStyle"></span>
//                    <span class="LeftAndRightSeparatorReal" style="display: none;"></span>
//                    <select class="LeftAndRightSeparatorSelectValuesDisplay LeftAndRightSeparatorSelectValuesDisplayStyle" style="display: none;"></select>
//                </span>
//                <span class="RightColumnTextboxPlaceHolder SortableWidgetItemComponentStyle">
//                    <span><span class="RightColumnTextboxDisplay TextboxDisplayStyle"></span></span>
//                    <span>
//                        <input class="RightColumnTextbox TextboxStyle" />
//                    </span>
//                    <span>
//                        <a class="RightColumnDropdownBtn DropdownBtnStyle" href="javascript:;">
//                            <span class="ui-icon ui-icon-triangle-1-s DropdownBtnPicStyle"></span>
//                        </a>
//                    </span>
//                </span>
//                <span class="ComponentSeparatorPlaceHolder SortableWidgetItemComponentStyle">
//                    <select class="ComponentSeparator"></select>
//                    <span class="ComponentSeparatorDisplay" style="display: none;"></span>
//                </span>
//                <span class="ComponentRemoveBtnPlaceHolder ComponentRemoveBtnPlaceHolderStyle SortableWidgetItemComponentStyle">
//                    <span class="ComponentRemoveBtn ComponentRemoveBtnStyle ui-icon ui-icon-closethick"></span>
//                </span>
//            </div>
//        </div>
//        <div class="SortableWidgetPlaceHolder toNextLine">
//            <div class="SortableWidget SortableWidgetStyle">
//            </div>
//        </div>
//        <div class="SortableWidgetBtnsPlaceHolder toNextLine">
//            <div class="SortableWidgetAddBtn WidgetBtnStyle WidgetBtnTextStyle m-btn">
//                Add
//            </div>
//            <div class="SortableWidgetCommitBtn WidgetBtnStyle WidgetBtnTextStyle m-btn green">
//                Commit
//            </div>
//            <div class="SortableWidgetClearBtn WidgetBtnStyle WidgetBtnTextStyle m-btn red">
//                Clear
//            </div>
//            <div class="SortableWidgetCancelBtn WidgetBtnStyle WidgetBtnTextStyle m-btn">
//                Cancel
//            </div>
//        </div>
//    </div>
//</div>

// ================================================== End of    HTML append ==================================================