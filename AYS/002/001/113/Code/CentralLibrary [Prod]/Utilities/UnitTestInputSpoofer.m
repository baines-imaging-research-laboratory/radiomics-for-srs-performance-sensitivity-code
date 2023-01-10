function xResponse = input(varargin)

global c1xSpoofedInputResponsesForUnitTest;

xResponse = c1xSpoofedInputResponsesForUnitTest{1};
c1xSpoofedInputResponsesForUnitTest = c1xSpoofedInputResponsesForUnitTest(2:end);

end

