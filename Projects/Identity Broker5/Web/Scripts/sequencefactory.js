(function ($) {
    // ================================================== Begin of   sequenceWidgetFactory ==================================================
    /// <summary>
    ///     Class : sequenceWidgetFactory
    /// </summary>
    var sequenceWidgetFactory = function (elementId, className, beforeCreate, afterCreate, sortableWidgetWidth, sortableWidgetItemWidth, columnMappingStrDisplay, columnMappingStrReal, columnMappingStrRealForDisplay, dragBtnTipStr, beforeEdit, afterEdit, beforeRemove, afterRemove, isShowedRemoveBtn, removeBtnTipStr, editBtnTipStr, isShowedLeftColumnTextDisplay, isShowedLeftColumnTextReal, beforeAdd, afterAdd, isShowedAddBtn, addBtnTipStr, beforeCommit, afterCommit, isShowedCommitBtn, commitBtnTipStr, beforeClear, afterClear, isShowedClearBtn, clearBtnTipStr, beforeCancel, afterCancel, isShowedCancelBtn, cancelBtnTipStr, isAlwaysShownColumnMappingStrFieldDisplay, isShowedComponentSeparatorDisplay, isShowedComponentSeparatorReal, componentSeparatorDefaultValue, componentSeparatorRealForDisplayDefaultValue, componentSeparatorDisplayDefaultValue) { ////// adding more parameter here
        // -------------------------------------- Begin of     Global variable --------------------------------------
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin of   element ~~~~~~~~~~~~~~~~~~~~~~~~~~
        this._elementId = "";   // this element Id.    E.g. "id"
        var _element = "";  // this element.    E.g. $("#id")
        var _className = ""; // this element class.  E.g. "className"

        // sortable widget HTML code
        var _htmlCodeStr = '<div class="SequenceComboBoxStyle"> <div class="ColumnMappingStrField toNextLine"> <div class="toNextLine" style="display: none;"> Display String : </div><div class="ColumnMappingStrFieldDisplay toNextLine"> AdapterA<br/> AdapterB<br/> AdapterC </div><div class="toNextLine" style="display: none;"> Real String : </div><div class="ColumnMappingStrFieldReal toNextLine" style="display: none;"> C55B08BF-053E-4DFA-BBBE-CAD433049F33::9A63FD6B-6F13-4737-A904-39CD13224FC8::D252F81A-FCAB-4EC2-AA65-AE3394A66256 </div><div class="ColumnMappingStrFieldRealForDisplay toNextLine" style="display: none;"> AdapterA**AdapterB**AdapterC </div><div class="ColumnMappingEditBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Edit </div></div><div class="ColumnMappingWidget toNextLine"> <div class="SortableWidgetTemplate" style="height: 0px; visibility: hidden; width: 0px;"> <div class="SortableWidgetItem SortableWidgetItemStyle ui-state-default" style="width: auto;"> <span class="SortableWidgetItemDragBtnPlaceHolder SortableWidgetItemComponentStyle DragBtnStyle"> <span class="SortableWidgetItemDragBtn ui-icon ui-icon-arrowthick-2-n-s"></span> </span> <span class="LeftColumnTextPlaceHolder SortableWidgetItemComponentStyle"> <span class="LeftColumnTextDisplay TextStyle"></span> <span class="LeftColumnTextReal" style="display: none;"></span> </span> <span class="ComponentSeparatorPlaceHolder SortableWidgetItemComponentStyle"> <span class="ComponentSeparatorDisplay"></span> <span class="ComponentSeparatorReal TextStyle" style="display: none;"></span> </span> <span class="ComponentRemoveBtnPlaceHolder ComponentRemoveBtnPlaceHolderStyle SortableWidgetItemComponentStyle"> <span class="ComponentRemoveBtn ComponentRemoveBtnStyle ui-icon ui-icon-closethick"></span> </span> </div></div><div class="SortableWidgetPlaceHolder toNextLine"> <div class="SortableWidget SortableWidgetStyle"> </div></div><div class="SortableWidgetBtnsPlaceHolder toNextLine"> <div class="SortableWidgetAddBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Add </div><div class="SortableWidgetCommitBtn WidgetBtnStyle WidgetBtnTextStyle m-btn green"> Commit </div><div class="SortableWidgetClearBtn WidgetBtnStyle WidgetBtnTextStyle m-btn red"> Clear </div><div class="SortableWidgetCancelBtn WidgetBtnStyle WidgetBtnTextStyle m-btn"> Cancel </div></div></div></div>';

        // .ColumnMappingStrField   // the place holder for the dn result string real and display element 
        var _columnMappingStrFieldElement = null; //_element.find(".ColumnMappingStrField");
        var _columnMappingStrFieldDisplayElement = null; // _columnMappingStrFieldElement.ColumnMappingStrFieldfind(".ColumnMappingStrFieldDisplay");
        var _columnMappingStrFieldRealElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingStrFieldReal");
        var _columnMappingStrFieldRealForDisplayElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingStrFieldRealForDisplay");
        var _columnMappingEditBtnElement = null; // _columnMappingStrFieldElement.find(".ColumnMappingEditBtn");

        // .ColumnMappingWidget element  // the component template to clone  
        var _columnMappingWidgetElement = null; //_element.find(".ColumnMappingWidget");       
        // .SortableWidgetItem element
        var _sortableWidgetItemElement = null; // _columnMappingWidgetElement.find(".SortableWidgetTemplate").find(".SortableWidgetItem")    

        // .SortableWidget element  // the cloned component object place holder
        var _sortableWidgetElement = null;    //_columnMappingWidgetElement.find(".SortableWidgetPlaceHolder").find(".SortableWidget")
        var _sortableWidgetWidth = "";     // inputSortableWidgetWidth.toString();      // E.g. "800px"
        var _sortableWidgetItemWidth = "";  // inputSortableWidgetItemWidth.toString();   // E.g. "600px"

        // .SortableWidgetBtnsPlaceHolder element   // the btns place holder
        var _sortableWidgetBtnsPlaceHolderElement = null;    // _columnMappingWidgetElement.find(".SortableWidgetBtnsPlaceHolder")  
        var _sortableWidgetAddBtnElement = null; // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetAddBtn") 
        var _sortableWidgetCommitBtnElement = null; // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCommitBtn")   
        var _sortableWidgetClearBtnElement = null; // _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetClearBtn")  
        var _sortableWidgetCancelBtnElement = null; //_sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCancelBtn"); 
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~ End of   element ~~~~~~~~~~~~~~~~~~~~~~~~~~

        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~
        // tool tip string
        var _dragBtnTipStr = ""; // Drage Btn tip
        var _editBtnTipStr = ""; // Edit btn tip
        var _removeBtnTipStr = "";  // Remove Btn tip
        var _addBtnTipStr = ""; // Add btn tip
        var _commitBtnTipStr = ""; // Commit btn tip
        var _clearBtnTipStr = ""; // Clear btn tip
        var _cancelBtnTipStr = ""; // Cancel btn tip
        // ~~~~~~~~~~~~~~~~~~~~~ End of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~


        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   eventHandler / Element btns callback event ~~~~~~~~~~~~~~~~~~~~~
        // CallBack Event
        var emptyFunction = function () { };
        var _beforeCreate = emptyFunction;
        var _afterCreate = emptyFunction;
        var _beforeEdit = emptyFunction;
        var _afterEdit = emptyFunction;
        var _beforeRemove = emptyFunction;
        var _afterRemove = emptyFunction;
        var _beforeAdd = emptyFunction;
        var _afterAdd = emptyFunction;
        var _beforeCommit = emptyFunction;
        var _afterCommit = emptyFunction;
        var _beforeClear = emptyFunction;
        var _afterClear = emptyFunction;
        var _beforeCancel = emptyFunction;
        var _afterCancel = emptyFunction;
        // ~~~~~~~~~~~~~~~~~~~~~ End of   eventHandler / Element btns callback event ~~~~~~~~~~~~~~~~~~~~~

        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~
        var _isShowedLeftColumnTextDisplay = false;     //inputIsShowedLeftColumnTextDisplay;  //  is Showed LeftColumnTextboxDisplay
        var _isShowedLeftColumnTextReal = false;     //inputIsShowedLeftColumnTextReal;    //  is Showed LeftColumnTextbox
        var _isShowedComponentSeparatorDisplay = false;     //inputIsShowedComponentSeparatorDisplay;  //  is Showed ComponentSeparator
        var _isShowedComponentSeparatorReal = false;     //inputIsShowedComponentSeparatorReal;
        var _isShowedRemoveBtn = false;     // inputIsShowedRemoveBtn;    // is showed RemoveBtn
        var _isShowedAddBtn = false;        // inputIsShowedAddBtn;    //  is Showed AddBtn
        var _isShowedCommitBtn = false;     // inputIsShowedCommitBtn;    //  is Showed CommitBtn
        var _isShowedClearBtn = false;     // inputIsShowedClearBtn;    //  is Showed ClearBtn
        var _isShowedCancelBtn = false;     // inputIsShowedCancelBtn;    //  is Showed CancelBtn
        var _isAlwaysShownColumnMappingStrFieldDisplay = false;       // show or hide the _columnMappingStrFieldDisplayElement which class=".ColumnMappingStrFieldDisplay".
        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~inputMappingStr

        // ~~~~~~~~~~~~~~~~~~~~~ Begin of   attribute setting ~~~~~~~~~~~~~~~~~~~~~
        var _columnMappingStrDisplay = "";    // inputColumnMappingStrDisplay;    //initial  .ColumnMappingStrFieldDisplay
        var _columnMappingStrReal = "";    // inputColumnMappingStrReal;    // initial  .ColumnMappingStrFieldReal
        var _columnMappingStrRealForDisplay = "";    // inputColumnMappingStrRealForDisplay;   // initial  .ColumnMappingStrFieldRealForDisplay

        // .ColumnMappingStrField attribute   // the place holder for the dn result string real and display element 

        // componentSeparator default value attribute
        var _componentSeparatorDefaultValue = null;
        var _componentSeparatorRealForDisplayDefaultValue = null;
        var _componentSeparatorDisplayDefaultValue = null;
        // ~~~~~~~~~~~~~~~~~~~~~ End of   attribute setting ~~~~~~~~~~~~~~~~~~~~~
        // -------------------------------------- End of     Global variable --------------------------------------




        // -------------------------------------- Begin of     Constructor --------------------------------------
        /// <summary>
        ///     The constructor
        /// </summary>
        /// <param name="inputElementId">this element id from HTML. </param>
        /// <param name="inputClassName">this element class name from HTML. </param>
        /// <param name="inputBeforeCreate">The event handler before create this widget.</param>
        /// <param name="inputAfterCreate">The event handler after create this widget.</param>
        /// <param name="inputSortableWidgetWidth">The width of the container .SortableWidget   of .SortableWidgetItem   E.g. "800px"</param>
        /// <param name="inputSortableWidgetItemWidth">the width of .SortableWidgetItem  E.g. "600px"</param>
        /// <param name="inputColumnMappingStrDisplay">initial  .ColumnMappingStrFieldDisplay</param>
        /// <param name="inputColumnMappingStrReal">initial  .ColumnMappingStrFieldReal</param>
        /// <param name="inputColumnMappingStrRealForDisplay">initial  .ColumnMappingStrFieldRealForDisplay</param>
        /// <param name="inputDragBtnTipStr">The tool tip for drag button.</param>
        /// <param name="inputBeforeEdit">The event handler before "edit" button click.</param>
        /// <param name="inputAfterEdit">The event handler after "edit" button click.</param>
        /// <param name="inputBeforeRemove">The event handler Before "Remove" button click.</param>
        /// <param name="inputAfterRemove">The event handler after "Remove" button click.</param>
        /// <param name="inputIsShowedRemoveBtn">whether to show the "Remove" button.</param>
        /// <param name="inputRemoveBtnTipStr">The tool tip for "Remove" button.</param>
        /// <param name="inputEditBtnTipStr">The tool tip for "edit" button.</param>
        /// <param name="inputIsShowedLeftColumnTextDisplay">whether to show the "LeftColumnTextDisplay".</param>
        /// <param name="inputIsShowedLeftColumnTextReal">whether to show the "LeftColumnTextReal"</param>
        /// <param name="inputBeforeAdd">The event handler before "Add" button click.</param>
        /// <param name="inputAfterAdd">The event handler after "Add" button click.</param>
        /// <param name="inputIsShowedAddBtn">whether to show the "Add" button.</param>
        /// <param name="inputAddBtnTipStr">The tool tip for "Add" button.</param>
        /// <param name="inputBeforeCommit">The event handler before "Commit" button click.</param>
        /// <param name="inputAfterCommit">The event handler after "Commit" button click.</param>
        /// <param name="inputIsShowedCommitBtn">whether to show the "Commit" button.</param>
        /// <param name="inputCommitBtnTipStr">The tool tip for "Commit" button.</param>
        /// <param name="inputBeforeClear">The event handler before "Clear" button click.</param>
        /// <param name="inputAfterClear">The event handler after "Clear" button click.</param>
        /// <param name="inputIsShowedClearBtn">whether to show the "Clear" button.</param>
        /// <param name="inputClearBtnTipStr">The tool tip for "Clear" button.</param>
        /// <param name="inputBeforeCancel">The event handler before "Cancel" button click.</param>
        /// <param name="inputAfterCancel">The event handler after "Cancel" button click.</param>
        /// <param name="inputIsShowedCancelBtn">whether to show the "Cancel" button.</param>
        /// <param name="inputCancelBtnTipStr">The tool tip for "Cancel" button.</param>
        /// <param name="inputIsAlwaysShownColumnMappingStrFieldDisplay">whether to always show the "ColumnMappingStrFieldDisplay" after press "Edit" button.</param>
        /// <param name="inputIsShowedComponentSeparatorDisplay">whether to show the "ComponentSeparatorDisplay".</param>
        /// <param name="inputIsShowedComponentSeparatorReal">whether to show the "ComponentSeparatorReal".</param>
        /// <param name="inputComponentSeparatorDefaultValue">The default value of Component Separator of  ".ColumnMappingStrFieldReal" </param>
        /// <param name="inputComponentSeparatorRealForDisplayDefaultValue">The default value of Component Separator of  ".ColumnMappingStrFieldRealForDisplay"</param>
        /// <param name="inputComponentSeparatorDisplayDefaultValue">The default value of Component Separator of  ".ColumnMappingStrFieldDisplay"</param>
        /// <returns>The factory instance</returns>
        this.construct = function (inputElementId, inputClassName, inputBeforeCreate, inputAfterCreate, inputSortableWidgetWidth, inputSortableWidgetItemWidth, inputColumnMappingStrDisplay, inputColumnMappingStrReal, inputColumnMappingStrRealForDisplay, inputDragBtnTipStr, inputBeforeEdit, inputAfterEdit, inputBeforeRemove, inputAfterRemove, inputIsShowedRemoveBtn, inputRemoveBtnTipStr, inputEditBtnTipStr, inputIsShowedLeftColumnTextDisplay, inputIsShowedLeftColumnTextReal, inputBeforeAdd, inputAfterAdd, inputIsShowedAddBtn, inputAddBtnTipStr, inputBeforeCommit, inputAfterCommit, inputIsShowedCommitBtn, inputCommitBtnTipStr, inputBeforeClear, inputAfterClear, inputIsShowedClearBtn, inputClearBtnTipStr, inputBeforeCancel, inputAfterCancel, inputIsShowedCancelBtn, inputCancelBtnTipStr, inputIsAlwaysShownColumnMappingStrFieldDisplay, inputIsShowedComponentSeparatorDisplay, inputIsShowedComponentSeparatorReal, inputComponentSeparatorDefaultValue, inputComponentSeparatorRealForDisplayDefaultValue, inputComponentSeparatorDisplayDefaultValue) {    ////// adding more parameter here
            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element ~~~~~~~~~~~~~~~~~~~~~
            this._elementId = inputElementId;   // this element Id.    E.g. "id"
            _element = $("#" + this._elementId);    // this element.    E.g. $("#id")
            _className = inputClassName;  // this element class.  E.g. "className"
            _element.addClass(_className);     // add className

            // append the sortable widget HTML code
            _element.append($.parseHTML(_htmlCodeStr));

            // .ColumnMappingStrField   // the place holder for the dn result string real and display element 
            _columnMappingStrFieldElement = _element.find(".ColumnMappingStrField");
            _columnMappingStrFieldDisplayElement = _columnMappingStrFieldElement.find(".ColumnMappingStrFieldDisplay");
            _columnMappingStrFieldRealElement = _columnMappingStrFieldElement.find(".ColumnMappingStrFieldReal");
            _columnMappingStrFieldRealForDisplayElement = _columnMappingStrFieldElement.find(".ColumnMappingStrFieldRealForDisplay");
            _columnMappingEditBtnElement = _columnMappingStrFieldElement.find(".ColumnMappingEditBtn");

            // .ColumnMappingWidget element  // the component template to clone  
            _columnMappingWidgetElement = _element.find(".ColumnMappingWidget");
            _sortableWidgetItemElement = _columnMappingWidgetElement.find(".SortableWidgetTemplate").find(".SortableWidgetItem");

            // .SortableWidget element  // the cloned component object place holder
            _sortableWidgetElement = _columnMappingWidgetElement.find(".SortableWidgetPlaceHolder").find(".SortableWidget");
            _sortableWidgetWidth = inputSortableWidgetWidth.toString();
            _sortableWidgetItemWidth = inputSortableWidgetItemWidth.toString();
            _sortableWidgetElement.css({ "float": "left", "width": _sortableWidgetWidth });   // E.g.  _sortableWidgetElement.css({ "float": "left", "width": "800px" })

            // .SortableWidgetBtnsPlaceHolder element   // the btns place holder
            _sortableWidgetBtnsPlaceHolderElement = _columnMappingWidgetElement.find(".SortableWidgetBtnsPlaceHolder");
            _sortableWidgetAddBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetAddBtn");
            _sortableWidgetCommitBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCommitBtn");
            _sortableWidgetClearBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetClearBtn")
            _sortableWidgetCancelBtnElement = _sortableWidgetBtnsPlaceHolderElement.find(".SortableWidgetCancelBtn");
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element ~~~~~~~~~~~~~~~~~~~~~

            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~
            // tip string
            _dragBtnTipStr = inputDragBtnTipStr;
            _editBtnTipStr = inputEditBtnTipStr;
            _removeBtnTipStr = inputRemoveBtnTipStr;
            _addBtnTipStr = inputAddBtnTipStr;
            _commitBtnTipStr = inputCommitBtnTipStr;
            _clearBtnTipStr = inputClearBtnTipStr;
            _cancelBtnTipStr = inputCancelBtnTipStr;
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element Tip Str ~~~~~~~~~~~~~~~~~~~~~

            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~
            // CallBack Event
            _beforeCreate = inputBeforeCreate;
            _afterCreate = inputAfterCreate;
            _beforeEdit = inputBeforeEdit;
            _afterEdit = inputAfterEdit;
            _beforeRemove = inputBeforeRemove;
            _afterRemove = inputAfterRemove;
            _beforeAdd = inputBeforeAdd;
            _afterAdd = inputAfterAdd;
            _beforeCommit = inputBeforeCommit;
            _afterCommit = inputAfterCommit;
            _beforeCancel = inputBeforeCancel;
            _afterCancel = inputAfterCancel;
            // ~~~~~~~~~~~~~~~~~~~~~ End of   Element btns callback event ~~~~~~~~~~~~~~~~~~~~~

            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~
            _isShowedLeftColumnTextDisplay = inputIsShowedLeftColumnTextDisplay;  //  is Showed LeftColumnTextboxDisplay
            _isShowedLeftColumnTextReal = inputIsShowedLeftColumnTextReal;    //  is Showed LeftColumnTextbox
            _isShowedComponentSeparatorDisplay = inputIsShowedComponentSeparatorDisplay;  //  is Showed ComponentSeparator
            _isShowedComponentSeparatorReal = inputIsShowedComponentSeparatorReal;
            _isShowedRemoveBtn = inputIsShowedRemoveBtn;    // is showed RemoveBtn
            _isShowedAddBtn = inputIsShowedAddBtn;    //  is Showed AddBtn
            _isShowedCommitBtn = inputIsShowedCommitBtn;    //  is Showed CommitBtn
            _isShowedClearBtn = inputIsShowedClearBtn;      //  is Showed ClearBtn
            _isShowedCancelBtn = inputIsShowedCancelBtn;    //  is Showed CancelBtn
            // ~~~~~~~~~~~~~~~~~~~~~ Begin of   isShowed ~~~~~~~~~~~~~~~~~~~~~inputMappingStr

            // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin of   value settings ~~~~~~~~~~~~~~~~~~~~~~~~~~
            _columnMappingStrDisplay = inputColumnMappingStrDisplay;    //initial  .ColumnMappingStrFieldDisplay
            _columnMappingStrReal = inputColumnMappingStrReal;    // initial  .ColumnMappingStrFieldReal
            _columnMappingStrRealForDisplay = inputColumnMappingStrRealForDisplay;   // initial  .ColumnMappingStrFieldRealForDisplay
            // .ColumnMappingStrField attribute   // the place holder for the dn result string real and display element 
            _isAlwaysShownColumnMappingStrFieldDisplay = inputIsAlwaysShownColumnMappingStrFieldDisplay;    // show or hide the _columnMappingStrFieldDisplayElement which class=".ColumnMappingStrFieldDisplay".
            if (_isAlwaysShownColumnMappingStrFieldDisplay) {
                _columnMappingStrFieldDisplayElement.addClass("isAlwaysShownColumnMappingStrFieldDisplay");
            }
            // componentSeparator default value attribute
            _componentSeparatorDefaultValue = inputComponentSeparatorDefaultValue;
            _componentSeparatorRealForDisplayDefaultValue = inputComponentSeparatorRealForDisplayDefaultValue;
            _componentSeparatorDisplayDefaultValue = inputComponentSeparatorDisplayDefaultValue;
            // ~~~~~~~~~~~~~~~~~~~~~~~~~~ End of   value settings ~~~~~~~~~~~~~~~~~~~~~~~~~~

            // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Begin of   Element value settings ~~~~~~~~~~~~~~~~~~~~~~~~~~
            _columnMappingStrFieldDisplayElement.html(_columnMappingStrDisplay);        //initial  .ColumnMappingStrFieldDisplay
            _columnMappingStrFieldRealElement.html(_columnMappingStrReal);      // initial  .ColumnMappingStrFieldReal
            _columnMappingStrFieldRealForDisplayElement.html(_columnMappingStrRealForDisplay);  // initial  .ColumnMappingStrFieldRealForDisplay
            // ~~~~~~~~~~~~~~~~~~~~~~~~~~ End of   Element value settings ~~~~~~~~~~~~~~~~~~~~~~~~~~

            return this;
        }; // End of     construct()
        // -------------------------------------- End of     Constructor --------------------------------------




        // -------------------------------------- Begin of    methods --------------------------------------
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
        ///     Hide the last component separator and show all other component separator.
        ///     Hide Component Separator DropDown PlaceHolder (E.g. , +) when this is the last Component.
        ///     and show Component Separator DropDown PlaceHolder (E.g. , +) when this is not the last Component.
        /// </summary>
        var HideOrShowComponentSeparatorAndHideLast = function () {
            // ClonedComponentSeparatorDisplay
            var clonedComponentSeparatorDisplayCollection = _element.find(".ColumnMappingWidget").find(".SortableWidgetPlaceHolder").find(".SortableWidget").find(".ClonedComponentSeparatorDisplay");
            var lastItemDisplay;
            clonedComponentSeparatorDisplayCollection.each(function () {
                if (_isShowedComponentSeparatorDisplay) {
                    lastItemDisplay = $(this).show(); // show() every item
                } else {
                    lastItemDisplay = $(this).hide(); // hide() every item
                }
            });
            if (lastItemDisplay != null) lastItemDisplay.hide(); // hide() the last itemDisplay

            // ClonedComponentSeparatorReal
            // We don't hide() the last itemReal
            var clonedComponentSeparatorRealCollection = _element.find(".ColumnMappingWidget").find(".SortableWidgetPlaceHolder").find(".SortableWidget").find(".ClonedComponentSeparatorReal");
            var lastItemReal;
            clonedComponentSeparatorRealCollection.each(function () {
                if (_isShowedComponentSeparatorReal) {
                    lastItemReal = $(this).show(); // show() every item
                } else {
                    lastItemReal = $(this).hide(); // hide() every item
                }
            });
        }; // End of    HideOrShowComponentSeparatorAndHideLast() 


        /// <summary>
        ///     Make sortable for SortableWidget in SortableWidgetPlaceHolder.
        ///     This method make Component become SortableWidget.
        /// </summary>
        var makeSortableWidget = function (sortableElement) {
            sortableElement.sortable({
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
                    HideOrShowComponentSeparatorAndHideLast();
                }
            });
            // sortableElement.disableSelection();
            // Disable selection of text content within the set of matched elements.
            // Disable the user to select the text from the sortable item
        }; // End of    makeSortableWidget()    // End of   var makeSortableWidget = function ()
        // -------------------------------------- End of    methods --------------------------------------




        // -------------------------------------- Begin of    cloneComponent --------------------------------------
        /// <summary>
        ///     Clone SortableWidgetItem by inputLeftColumnStr, inputLeftColumnStrRealForDisplay, and inputComponentSeparatorStr
        ///     E.g 1.
        ///     inputLeftColumnStr === "C55B08BF-053E-4DFA-BBBE-CAD433049F33"
        ///     inputLeftColumnStrRealForDisplay = "AdapterA"
        ///     inputComponentSeparatorStr === "::"
        ///     Then:
        ///     Create a SortableWidgetItem with all value
        ///     E.g 2.
        ///     inputLeftColumnStr === ""
        ///     inputLeftColumnStrRealForDisplay = ""
        ///     inputComponentSeparatorStr === ""
        ///     Then:
        ///     Create a SortableWidgetItem with no value
        /// </summary>
        /// <param name="inputLeftColumnStr">Single left column string.     E.g. one of item from { "C55B08BF-053E-4DFA-BBBE-CAD433049F33"  , "9A63FD6B-6F13-4737-A904-39CD13224FC8"  ,  "D252F81A-FCAB-4EC2-AA65-AE3394A66256" }</param>
        /// <param name="inputComponentSeparatorStr">Single input component separator array real.      E.g. one of item from { "::"  ,  "::"  ,  "::"} == { componentSeparatorDefaultValue  ,  componentSeparatorDefaultValue  , componentSeparatorDefaultValue } </param>
        /// <param name="inputLeftColumnStrRealForDisplay">Single input component array real for display.      E.g. one of item from { "AdapterA" , "AdapterB" , "AdapterC"}</param>
        /// <param name="inputComponentSeparatorRealForDisplayStr">Single input component separator RealForDisplay array .      E.g. one of item from { "**"  ,  "**"  ,  "**"} == { componentSeparatorRealForDisplayDefaultValue  ,  componentSeparatorRealForDisplayDefaultValue  , componentSeparatorRealForDisplayDefaultValue } </param>
        var cloneComponent = function (inputLeftColumnStr, inputComponentSeparatorStr, inputLeftColumnStrRealForDisplay, inputComponentSeparatorRealForDisplayStr) {
            // ~~~~~~~ Begin of    All cloneComponent Defination ~~~~~~~
            // add .Cloned...  class to every sub element.
            var clonedSortableWidgetItem = _sortableWidgetItemElement.eq(0).clone();    // .SortableWidgetItem
            clonedSortableWidgetItem = clonedSortableWidgetItem.addClass("ClonedSortableWidgetItem");
            clonedSortableWidgetItem.css({ "float": "left", "width": _sortableWidgetItemWidth });   // E.g.  _sortableWidgetItemElement.css({ "float": "left", "width": "581px" })

            // drag btn
            var sortableWidgetItemDragBtn = clonedSortableWidgetItem.find(".SortableWidgetItemDragBtn").addClass("ClonedSortableWidgetItemDragBtn");
            // left column
            var leftColumnTextDisplay = clonedSortableWidgetItem.find(".LeftColumnTextDisplay").addClass("ClonedLeftColumnTextDisplay");
            var LeftColumnTextReal = clonedSortableWidgetItem.find(".LeftColumnTextReal").addClass("ClonedLeftColumnTextReal");
            // component separator
            var componentSeparatorPlaceHolder = clonedSortableWidgetItem.find(".ComponentSeparatorPlaceHolder").addClass("ClonedComponentSeparatorPlaceHolder");
            var componentSeparatorDisplay = clonedSortableWidgetItem.find(".ComponentSeparatorDisplay").addClass("ClonedComponentSeparatorDisplay");
            var ComponentSeparatorReal = clonedSortableWidgetItem.find(".ComponentSeparatorReal").addClass("ClonedComponentSeparatorReal");
            // remove btn
            var componentRemoveBtn = clonedSortableWidgetItem.find(".ComponentRemoveBtn").addClass("ClonedComponentRemoveBtn");
            // ~~~~~~~ End of    All cloneComponent Defination ~~~~~~~

            // ~~~~~~~ Begin of    attributes setting ~~~~~~~
            // add tool tip
            sortableWidgetItemDragBtn.attr("title", _dragBtnTipStr);

            // componentRemoveBtn : Apply component Remove btn click event
            componentRemoveBtn.on("click", function (event) {
                clonedSortableWidgetItem.remove();
                HideOrShowComponentSeparatorAndHideLast();
            });
            // ~~~~~~~ End of    attributes setting ~~~~~~~

            // ~~~~~~~ Begin of    Set the value from parameter ~~~~~~~
            leftColumnTextDisplay.html(inputLeftColumnStrRealForDisplay);
            LeftColumnTextReal.html(inputLeftColumnStr);
            componentSeparatorDisplay.html(inputComponentSeparatorRealForDisplayStr);
            ComponentSeparatorReal.html(inputComponentSeparatorStr);
            // ~~~~~~~ End of    Set the value from parameter ~~~~~~~

            // append / paste the code to    sortableWidgetPlaceHolder  
            _sortableWidgetElement.append(clonedSortableWidgetItem);    // append the Cloned Component (SortableWidgetItem) to      .SortableWidgetPlaceHolder .SortableWidget

            // ~~~~~~~ Begin of    Hide and show ~~~~~~~
            HideOrShowComponentSeparatorAndHideLast();
            if (_isShowedLeftColumnTextDisplay) {
                leftColumnTextDisplay.show();
            } else {
                leftColumnTextDisplay.hide();
            }
            if (_isShowedLeftColumnTextReal) {
                LeftColumnTextReal.show();
            } else {
                LeftColumnTextReal.hide();
            }
            if (_isShowedRemoveBtn) {
                componentRemoveBtn.show();
            } else {
                componentRemoveBtn.hide();
            }
            // ~~~~~~~ End of    Hide and show ~~~~~~~
        };
        // -------------------------------------- End of    cloneComponent --------------------------------------




        // -------------------------------------- Begin of    other methods --------------------------------------
        /// <summary>
        ///     1.
        ///     Private method - clear all component.
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
        };  // End of   privateClearAllComponent() 

        /// <summary>
        ///     Deserialize from component arr to sortable SortableWidgetItem
        /// </summary>
        /// <param name="componentArrLength">Length of component array E.g. componentArr.length === 3</param>
        /// <param name="inputComponentArr">input component array. E.g. { "C55B08BF-053E-4DFA-BBBE-CAD433049F33"  , "9A63FD6B-6F13-4737-A904-39CD13224FC8"  ,  "D252F81A-FCAB-4EC2-AA65-AE3394A66256" }</param>
        /// <param name="componentSeparatorArr">component separator array E.g. { "::"  ,  "::"  ,  "::"} == { componentSeparatorDefaultValue  ,  componentSeparatorDefaultValue  , componentSeparatorDefaultValue } </param>
        /// <param name="inputComponentRealForDisplayArr">input component array real for display. E.g. { "AdapterA" , "AdapterB" , "AdapterC"}</param>
        /// <param name="componentSeparatorRealForDisplayArr">component separator RealForDisplay array E.g. { "**"  ,  "**"  ,  "**"} == { componentSeparatorRealForDisplayDefaultValue  ,  componentSeparatorRealForDisplayDefaultValue  , componentSeparatorRealForDisplayDefaultValue } </param>
        var deserializeComponentArrToSortableWidget = function (componentArrLength, inputComponentArr, componentSeparatorArr, inputComponentRealForDisplayArr, componentSeparatorRealForDisplayArr) {
            for (var i = 0; i < componentArrLength; i++) {
                cloneComponent(inputComponentArr[i], componentSeparatorArr[i], inputComponentRealForDisplayArr[i], componentSeparatorRealForDisplayArr[i]);
            }
        };


        /// <summary>
        ///     1.
        ///     Private method 
        ///     deserialize mapping string to components
        ///     E.g.
        ///     inputMappingStr  ===    C55B08BF-053E-4DFA-BBBE-CAD433049F33::9A63FD6B-6F13-4737-A904-39CD13224FC8::D252F81A-FCAB-4EC2-AA65-AE3394A66256
        ///     deserialize to component
        ///     2.
        ///     PS: privateClearAllComponent() method and clearAllComponent() method must be after cloneComponent() method
        ///     privateDeserializeMappingStrToComponent() method and deserializeMappingStrToComponent() method must be after privateClearAllComponent() method and clearAllComponent()
        /// </summary>
        /// <param name="inputMappingStr">input mapping string. e.g. C55B08BF-053E-4DFA-BBBE-CAD433049F33::9A63FD6B-6F13-4737-A904-39CD13224FC8::D252F81A-FCAB-4EC2-AA65-AE3394A66256</param>
        /// <returns>current object</returns>
        var privateDeserializeMappingStrToComponent = function (inputMappingStr, inputMappingStrRealForDisplay) {
            privateClearAllComponent();    // Clear all Component, before deserializing mapping string to component

            // For ColumnMappingStrFieldReal
            // E.g.
            // inputMappingStr  ===    C55B08BF-053E-4DFA-BBBE-CAD433049F33::9A63FD6B-6F13-4737-A904-39CD13224FC8::D252F81A-FCAB-4EC2-AA65-AE3394A66256 
            // will return  [componentArr, componentSeparatorArr, componentArr.length]
            // In this case, 
            //      _mappingStrToComponentArr[0] === componentArr === { "C55B08BF-053E-4DFA-BBBE-CAD433049F33"  , "9A63FD6B-6F13-4737-A904-39CD13224FC8"  ,  "D252F81A-FCAB-4EC2-AA65-AE3394A66256" }
            //      _mappingStrToComponentArr[1] === componentSeparatorArr === { "::"  ,  "::"  ,  "::"} === { componentSeparatorDefaultValue  ,  componentSeparatorDefaultValue , componentSeparatorDefaultValue } 
            //      _mappingStrToComponentArr[2] === componentArr.length === 3
            var componentArr = (new mappingStrConverterForSerializationHelper()).setMappingStrToComponentArr(inputMappingStr, [_componentSeparatorDefaultValue], [_componentSeparatorDefaultValue])._mappingStrToComponentArr;

            // For ColumnMappingStrFieldRealForDisplay
            // E.g.
            // inputMappingStrRealForDisplay ==    AdapterA<br/>AdapterB<br/>AdapterC
            // will return  [componentRealForDisplayArr, componentSeparatorRealForDisplayArr, componentRealForDisplayArr.length]
            // In this case, 
            //      _mappingStrToComponentArr[0] === componentArr === { "AdapterA"  , "AdapterB", "AdapterC" }
            //      _mappingStrToComponentArr[1] === componentSeparatorRealForDisplayArr === { "**"  ,  "**"  ,  "**"} === { componentSeparatorRealForDisplayDefaultValue  ,  componentSeparatorRealForDisplayDefaultValue , componentSeparatorRealForDisplayDefaultValue } 
            //      _mappingStrToComponentArr[2] === componentArr.length === 3
            var componentRealForDisplayArr = (new mappingStrConverterForSerializationHelper()).setMappingStrToComponentArr(inputMappingStrRealForDisplay, [_componentSeparatorRealForDisplayDefaultValue], [_componentSeparatorRealForDisplayDefaultValue])._mappingStrToComponentArr;

            // error check
            if (!(componentArr[2] == componentRealForDisplayArr[2])) {
                alert("Something wrong in privateDeserializeMappingStrToComponent , !(componentArr[2] == componentRealForDisplayArr[2])");
            }

            deserializeComponentArrToSortableWidget(componentArr[2], componentArr[0], componentArr[1], componentRealForDisplayArr[0], componentRealForDisplayArr[1]);
            return this;
        };  // End of   privateDeserializeMappingStrToComponent
        // -------------------------------------- End of    other methods --------------------------------------







        // --------------------------------------------------- Begin of    Btn Handler ---------------------------------------------------
        /// <summary>
        ///     Edit btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var editBtnClickHandler = function (event) {
            _beforeEdit(event); // before edit btn click event
            privateClearAllComponent();
            // deserialize mapping string to SortableWidgetItem
            privateDeserializeMappingStrToComponent(_columnMappingStrFieldRealElement.html(), _columnMappingStrFieldRealForDisplayElement.html());

            _columnMappingWidgetElement.show(); // show the ColumnMappingWidget
            _columnMappingEditBtnElement.hide(); // Hide the Edit Btn
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.hide(); // hide the .ColumnMappingStrFieldDisplay    
            _afterEdit(event);  // after edit btn click event
        }; // End of     editBtnClickHandler(event) 


        /// <summary>
        ///     Add btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var addBtnClickHandler = function (event) {
            _beforeAdd(event); // before add btn click event
            cloneComponent("", _componentSeparatorDefaultValue, "", _componentSeparatorRealForDisplayDefaultValue);
            _afterAdd(event) // after add btn click event
        }; // End of     addBtnClickHandler(event)    


        /// <summary>
        ///     Clear btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var clearBtnClickHandler = function (event) {
            _beforeClear(event);   // before clear btn click event
            privateClearAllComponent();
            _afterClear(event);    // after clear btn click event
        };  // End of   clearBtnClickHandler(event)  


        /// <summary>
        ///     Commit btn click handler
        ///     it will produce the mappingStrReal and mappingStrRealDisplay,
        ///     then mappingStrReal will have to do replaceWithEscapedSymbol
        /// </summary>
        /// <param name="event">Event.</param>
        var commitBtnClickHandler = function (event) {
            _beforeCommit(event);   // before commit btn click event

            var clonedLeftColumnTextDisplayCollection = _sortableWidgetElement.find(".ClonedLeftColumnTextDisplay");
            var clonedLeftColumnTextRealCollection = _sortableWidgetElement.find(".ClonedLeftColumnTextReal");
            var clonedComponentSeparatorDisplayCollection = _sortableWidgetElement.find(".ClonedComponentSeparatorDisplay");
            var clonedComponentSeparatorRealCollection = _sortableWidgetElement.find(".ClonedComponentSeparatorReal");
            var mappingStrDisplay = ""; // .ColumnMappingStrFieldDisplay    // _columnMappingStrFieldDisplayElement
            var mappingStrReal = "";    // .ColumnMappingStrFieldReal   // _columnMappingStrFieldRealElement
            var mappingStrRealForDisplay = "";    // .ColumnMappingStrFieldRealForDisplay   // _columnMappingStrFieldRealForDisplayElement

            var clonedLeftColumnTextRealCollectionLength = clonedLeftColumnTextRealCollection.length;
            for (var i = 0; i < clonedLeftColumnTextRealCollectionLength; i++) {
                var leftColumnStrDisplay = $.trim(clonedLeftColumnTextDisplayCollection.eq(i).html());     // str
                var leftColumnStrReal = $.trim(clonedLeftColumnTextRealCollection.eq(i).html());     // str

                var componentSeparatorStrDisplay = _componentSeparatorDisplayDefaultValue;
                var componentSeparatorStrReal = $.trim(clonedComponentSeparatorRealCollection.eq(i).html()); // str
                var componentSeparatorStrRealForDisplay = $.trim(clonedComponentSeparatorDisplayCollection.eq(i).html()); // str

                if (i === clonedLeftColumnTextRealCollectionLength - 1) {
                    // if this is the last component
                    mappingStrDisplay = mappingStrDisplay + leftColumnStrDisplay;
                    mappingStrReal = mappingStrReal + leftColumnStrReal;
                    mappingStrRealForDisplay = mappingStrRealForDisplay + leftColumnStrDisplay;
                } else {
                    // if this is not the last component
                    mappingStrDisplay = mappingStrDisplay + (leftColumnStrDisplay + componentSeparatorStrDisplay);
                    mappingStrReal = mappingStrReal + (leftColumnStrReal + componentSeparatorStrReal);
                    mappingStrRealForDisplay = mappingStrRealForDisplay + (leftColumnStrDisplay + componentSeparatorStrRealForDisplay);
                }
            }
            _columnMappingStrFieldDisplayElement.html(mappingStrDisplay);
            _columnMappingStrFieldRealElement.html(mappingStrReal);
            _columnMappingStrFieldRealForDisplayElement.html(mappingStrRealForDisplay);

            // Hide and Show
            _columnMappingEditBtnElement.show(); // Show the Edit Btn
            _columnMappingWidgetElement.hide(); // hide the ColumnMappingWidget
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.show(); // show the .ColumnMappingStrFieldDisplay    

            _afterCommit(event, mappingStrDisplay, mappingStrReal, mappingStrRealForDisplay);   // after commit btn click event
        }; // End of    commitBtnClickHandler(event)  


        /// <summary>
        ///     Cancel btn click handler
        /// </summary>
        /// <param name="event">Event.</param>
        var cancelBtnClickHandler = function (event) {
            _beforeCancel(event);   // before cancel btn click event
            privateClearAllComponent();
            _columnMappingEditBtnElement.show();
            _columnMappingWidgetElement.hide(); // hide the ColumnMappingWidget
            if (!_columnMappingStrFieldDisplayElement.hasClass("isAlwaysShownColumnMappingStrFieldDisplay")) _columnMappingStrFieldDisplayElement.show(); // show the .ColumnMappingStrFieldDisplay    
            _afterCancel(event);    // after cancel btn click event
        }; // End of     function cancelBtnClickHandler(event)    
        // --------------------------------------------------- End of    Btn Handler ---------------------------------------------------




        // -------------------------------------- Begin of    createFactory --------------------------------------
        /// <summary>
        ///     create the factory
        /// </summary>
        /// <returns>The factory instance</returns>
        this.createFactory = function () {
            _beforeCreate(event);   // before commit btn click event

            // hide the ColumnMappingWidget  before press Edit Button
            _columnMappingWidgetElement.hide();
            // Make Sortable 
            makeSortableWidget(_sortableWidgetElement);

            // Set "Edit", "Commit", "Cancel" Btn click event handler
            _columnMappingEditBtnElement.on("click", editBtnClickHandler);    // (Set the "Edit" Btn) Register the editBtnClickHandler Event 
            _sortableWidgetAddBtnElement.on("click", addBtnClickHandler);   // (Set the "Add" Btn) Register the addBtnClickHandler Click Event 
            _sortableWidgetCommitBtnElement.on("click", commitBtnClickHandler); // (Set the "Commit" Btn) Register the commitBtnClickHandler Event  
            _sortableWidgetClearBtnElement.on("click", clearBtnClickHandler);   // (Set the "Clear" Btn) Register the clearBtnClickHandler Event
            _sortableWidgetCancelBtnElement.on("click", cancelBtnClickHandler);  // (Set the "Cancel" Btn) Register the cancelBtnClickHandler Event 

            // Tooltip
            _columnMappingEditBtnElement.attr("title", _editBtnTipStr);  // Edit Btn tip
            _sortableWidgetAddBtnElement.attr("title", _addBtnTipStr);  // Add Btn tip
            _sortableWidgetCommitBtnElement.attr("title", _commitBtnTipStr);  // Commit Btn tip
            _sortableWidgetClearBtnElement.attr("title", _clearBtnTipStr);  // Clear Btn tip
            _sortableWidgetCancelBtnElement.attr("title", _cancelBtnTipStr);  // Cancel Btn tip

            // deserialize mapping string to SortableWidgetItem
            privateDeserializeMappingStrToComponent(_columnMappingStrFieldRealElement.html(), _columnMappingStrFieldRealForDisplayElement.html());

            // Hide or Show the main buttons whcih includes "Add button", "Commit button", "Clear button", "Cancel button"
            hideOrShowMainBtns();

            _afterCreate(event);   // after commit btn click event
            return this;
        };

        this.construct(elementId, className, beforeCreate, afterCreate, sortableWidgetWidth, sortableWidgetItemWidth, columnMappingStrDisplay, columnMappingStrReal, columnMappingStrRealForDisplay, dragBtnTipStr, beforeEdit, afterEdit, beforeRemove, afterRemove, isShowedRemoveBtn, removeBtnTipStr, editBtnTipStr, isShowedLeftColumnTextDisplay, isShowedLeftColumnTextReal, beforeAdd, afterAdd, isShowedAddBtn, addBtnTipStr, beforeCommit, afterCommit, isShowedCommitBtn, commitBtnTipStr, beforeClear, afterClear, isShowedClearBtn, clearBtnTipStr, beforeCancel, afterCancel, isShowedCancelBtn, cancelBtnTipStr, isAlwaysShownColumnMappingStrFieldDisplay, isShowedComponentSeparatorDisplay, isShowedComponentSeparatorReal, componentSeparatorDefaultValue, componentSeparatorRealForDisplayDefaultValue, componentSeparatorDisplayDefaultValue); ////// adding more parameter here
    }
    // -------------------------------------- End of    createFactory --------------------------------------
    // ================================================== End of   sequenceWidgetFactory ==================================================



    // ================================================== Begin of   sequenceStrGenerator jQuery Plugin ==================================================
    // ======================= Begin of     sequenceWidgetAgent =======================
    /// <summary>
    ///     Class : The agent which can access sequenceWidgetAgent.
    /// </summary>
    /// <param name="element">The element from HTML. </param>
    /// <param name="option">The default value</param>
    var sequenceWidgetAgent = function (element, options) {
        var emptyFunction = function (event, eventArgs) { };
        var _element = element;
        var _defaults = {
            className: "SequenceWidgetFactory",
            beforeCreate: emptyFunction, // before create factory
            afterCreate: emptyFunction, // after create factory
            sortableWidgetWidth: "600px",   // The width of the container .SortableWidget   of .SortableWidgetItem // E.g. "800px"
            sortableWidgetItemWidth: "500px",   // the width of .SortableWidgetItem  // E.g. "600px"
            columnMappingStrDisplay: "",    // .ColumnMappingStrFieldDisplay
            columnMappingStrReal: "",   // .ColumnMappingStrFieldReal   
            columnMappingStrRealForDisplay: "",   // .ColumnMappingStrFieldRealForDisplay
            dragBtnTipStr: "Click and drag.",
            beforeEdit: emptyFunction,
            afterEdit: emptyFunction,
            beforeRemove: emptyFunction,
            afterRemove: emptyFunction,
            isShowedRemoveBtn: false,
            removeBtnTipStr: "Click to remove.",
            editBtnTipStr: "Edit the sequence.",
            isShowedLeftColumnTextDisplay: true,
            isShowedLeftColumnTextReal: false,
            beforeAdd: emptyFunction,
            afterAdd: emptyFunction,
            isShowedAddBtn: false,
            addBtnTipStr: "Add new component.",
            beforeCommit: emptyFunction,
            afterCommit: emptyFunction, // afterCommit(event, mappingStrDisplay, mappingStrReal, mappingStrRealForDisplay);
            isShowedCommitBtn: true,
            commitBtnTipStr: "Commit the current configuration.",
            beforeClear: emptyFunction,
            afterClear: emptyFunction,
            isShowedClearBtn: false,
            clearBtnTipStr: "Clear the current configuration.",
            beforeCancel: emptyFunction,
            afterCancel: emptyFunction,
            isShowedCancelBtn: true,
            cancelBtnTipStr: "Cancel the editing configuration.",
            isAlwaysShownColumnMappingStrFieldDisplay: true,
            isShowedComponentSeparatorDisplay: false,
            isShowedComponentSeparatorReal: false,
            componentSeparatorDefaultValue: "::",   // The componentSeparator for  .ColumnMappingStrFieldReal
            componentSeparatorRealForDisplayDefaultValue: "**",     // The componentSeparator for .ColumnMappingStrFieldRealForDisplay
            componentSeparatorDisplayDefaultValue: '<br>'   // The componentSeparator for ColumnMappingStrFieldDisplay
            ////// adding more parameter here
        };
        var _config = $.extend(_defaults, options || {}); // options can be null or {} or something or the defaults

        // create new factory
        var _mySequenceWidgetFactory = (new sequenceWidgetFactory(_element.attr("id"), _config.className, _config.beforeCreate, _config.afterCreate, _config.sortableWidgetWidth, _config.sortableWidgetItemWidth, _config.columnMappingStrDisplay, _config.columnMappingStrReal, _config.columnMappingStrRealForDisplay, _config.dragBtnTipStr, _config.beforeEdit, _config.afterEdit, _config.beforeRemove, _config.afterRemove, _config.isShowedRemoveBtn, _config.removeBtnTipStr, _config.editBtnTipStr, _config.isShowedLeftColumnTextDisplay, _config.isShowedLeftColumnTextReal, _config.beforeAdd, _config.afterAdd, _config.isShowedAddBtn, _config.addBtnTipStr, _config.beforeCommit, _config.afterCommit, _config.isShowedCommitBtn, _config.commitBtnTipStr, _config.beforeClear, _config.afterClear, _config.isShowedClearBtn, _config.clearBtnTipStr, _config.beforeCancel, _config.afterCancel, _config.isShowedCancelBtn, _config.cancelBtnTipStr, _config.isAlwaysShownColumnMappingStrFieldDisplay, _config.isShowedComponentSeparatorDisplay, _config.isShowedComponentSeparatorReal, _config.componentSeparatorDefaultValue, _config.componentSeparatorRealForDisplayDefaultValue, _config.componentSeparatorDisplayDefaultValue)).createFactory();   ////// adding more parameter here
    };
    // ======================= Begin of     sequenceWidgetAgent =======================

    /// <summary>
    ///     sequenceStrGenerator
    /// </summary>
    $.fn.sequenceStrGenerator = function (options) {
        return this.each(function () {
            var element = $(this);    // $(this) means a single element from the "this" selected elements collection
            if (!element.data("sequenceStrGenerator")) element.data("sequenceStrGenerator", (new sequenceWidgetAgent(element, options)));  // if the element hasn't had the plugin, then create the plugin, use agent to get factory
        });
    };
    // ================================================== Begin of   sequenceStrGenerator jQuery Plugin ==================================================

})(jQuery);





//<div class="SequenceComboBoxStyle">
//    <div class="ColumnMappingStrField toNextLine">
//        <div class="toNextLine" style="display: none;">
//            Display String :
//        </div>
//        <div class="ColumnMappingStrFieldDisplay toNextLine">
//            AdapterA<br/>
//            AdapterB<br/>
//            AdapterC
//        </div>
//        <div class="toNextLine" style="display: none;">
//            Real String :
//        </div>
//        <div class="ColumnMappingStrFieldReal toNextLine" style="display: none;">
//            C55B08BF-053E-4DFA-BBBE-CAD433049F33::9A63FD6B-6F13-4737-A904-39CD13224FC8::D252F81A-FCAB-4EC2-AA65-AE3394A66256
//        </div>
//        <div class="ColumnMappingStrFieldRealForDisplay toNextLine" style="display: none;">
//            AdapterA**AdapterB**AdapterC
//        </div>
//        <div class="ColumnMappingEditBtn WidgetBtnStyle WidgetBtnTextStyle m-btn">
//            Edit
//        </div>
//    </div>
//    <div class="ColumnMappingWidget toNextLine">
//        <div class="SortableWidgetTemplate" style="height: 0px; visibility: hidden; width: 0px;">
//            <div class="SortableWidgetItem SortableWidgetItemStyle ui-state-default" style="width: auto;">
//                <span class="SortableWidgetItemDragBtnPlaceHolder SortableWidgetItemComponentStyle DragBtnStyle">
//                    <span class="SortableWidgetItemDragBtn ui-icon ui-icon-arrowthick-2-n-s"></span>
//                </span>
//                <span class="LeftColumnTextPlaceHolder SortableWidgetItemComponentStyle">
//                    <span class="LeftColumnTextDisplay TextStyle"></span>
//                    <span class="LeftColumnTextReal" style="display: none;"></span>
//                </span>
//                <span class="ComponentSeparatorPlaceHolder SortableWidgetItemComponentStyle">
//                    <span class="ComponentSeparatorDisplay"></span>
//                    <span class="ComponentSeparatorReal TextStyle" style="display: none;"></span>
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
// ======================================================================================