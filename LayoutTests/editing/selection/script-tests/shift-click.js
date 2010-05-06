description("Tests that shift+clicking does the platform correct behavior.");

var first = document.createElement('div');
first.innerHTML = 'one <span id="start"></span>two three';
document.body.appendChild(first);

var second = document.createElement('div');
second.innerHTML = 'four <span id="end"></span>five six';
document.body.appendChild(second);

var start = document.getElementById('start');
var end = document.getElementById('end');

function shiftClick(x, y, macExpected, otherExpected)
{
    eventSender.mouseMoveTo(x, y);
    eventSender.mouseDown(0, ['shiftKey']);
    eventSender.mouseUp(0, ['shiftKey']);
    assertSelectionString(macExpected, otherExpected);
}

var onMac = navigator.userAgent.search(/\bMac OS X\b/) != -1;

function assertSelectionString(macExpected, otherExpected)
{
    var expected = onMac ? macExpected : otherExpected;
    if (window.getSelection().toString() == expected)
        testPassed('window.getSelection().toString() is correct');
    else
        testFailed('window.getSelection().toString() is "' + window.getSelection().toString() + '" and should be "' + expected + '"');
}

function assertSelectionOrder(direction)
{
    var expectedPosition;
    if (direction == 'forward')
        expectedPosition = Node.DOCUMENT_POSITION_FOLLOWING;
    else if (direction == 'backward')
        expectedPosition = Node.DOCUMENT_POSITION_PRECEDING;
    
    var sel = window.getSelection();
    if (sel.anchorNode.compareDocumentPosition(sel.focusNode) == expectedPosition)
        testPassed("Selection direction is correct.");
    else
        testFailed("Selection direction is not correct. Expected a " + direction + " selection." + selectionAsString(sel));
}

// Double-click select to get around eventSender bug where it won't select
// text just using single-click.
if (window.eventSender) {
    eventSender.mouseMoveTo(start.offsetLeft, start.offsetTop);
    eventSender.mouseDown();
    eventSender.mouseUp();
    eventSender.mouseDown();

    eventSender.mouseMoveTo(end.offsetLeft, end.offsetTop);
    eventSender.mouseUp();

    assertSelectionString('two three\nfour five', 'two three\nfour five')
    assertSelectionOrder('forward');

    shiftClick(second.offsetLeft + second.offsetWidth, second.offsetTop, 'two three\nfour five six', 'two three\nfour five six');
    assertSelectionOrder('forward');
        
    shiftClick(end.offsetLeft, end.offsetTop, 'two three\nfour five', 'two three\nfour five');
    assertSelectionOrder('forward');

    // These two fail on Mac due to https://bugs.webkit.org/show_bug.cgi?id=36256.
    // In the first shiftClick call, the space after five is selected and shouldn't be.
    // In the second shiftClick call, "six" is selected and shouldn't be.
    shiftClick(first.offsetLeft, first.offsetTop, 'one two three\nfour five', 'one two');
    assertSelectionOrder('backward');

    shiftClick(start.offsetLeft, start.offsetTop, 'two three\nfour five', 'two');
    // FIXME: The selection direction is incorrect on Win/Linux here. It should be backward.
    assertSelectionOrder('backward');
}

var successfullyParsed = true;
