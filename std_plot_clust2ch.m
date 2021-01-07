% Figure1() - Plot the comparison between single-channel backprojection of all
%                       ICs vs. selected ICs, computes percent variance accounted for (PVAF)
%                       or ara under a curve (AUC) for the specified window. Note that this
%                       PVAF takes DC difference into account, so not the same as PVAF used in
%                       envtopo().
          
% Author: Makoto Miyakoshi, JSPS/SCCN,INC,UCSD
% History
% 09/18/2018 Makoto. Tried to fix the size issue on Windows 10 but unable to find the problem or solution.
% 09/17/2018 Makoto. Debugged for the case of combined conditions. Thanks Lizzy Blundon!
% 07/27/2018 Makoto. Developed into std_clust2ch. Now PVAF accounts for DC (time-domain PVAF). pvafTopo supported. Area under a curve (AUC) supported.
% 05/22/2015 ver 1.4 by Makoto. Renamed ('backprojection' is wrong, it's a forward projection)
% 01/08/2015 ver 1.3 by Makoto. Major update.
% 06/28/2013 ver 1.2 by Makoto. submenu = uimenu( std, 'label', 'Backproj from clst to chan', 'userdata', 'startup:off;study:on');
% 01/10/2013 ver 1.1 by Makoto. Minor changes.
% 10/26/2012 ver 1.0 by Makoto. Created.

% Copyright (C) 2012, Makoto Miyakoshi JSPS/SCCN,INC,UCSD
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



function varargout = std_plot_clust2ch(varargin)
% FIGURE1 MATLAB code for Figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before std_plot_clust2ch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to std_plot_clust2ch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Figure1

% Last Modified by GUIDE v2.5 18-Sep-2018 17:47:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @std_plot_clust2ch_OpeningFcn, ...
                   'gui_OutputFcn',  @std_plot_clust2ch_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Figure1 is made visible.
function std_plot_clust2ch_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Figure1 (see VARARGIN)

% Import data from base workspace.
ALLEEG = evalin('base', 'ALLEEG');
STUDY  = evalin('base', 'STUDY');

% Check if STUDY.clust2ch is precomputed.
if ~isfield(STUDY, 'clust2ch')
    error('Precompute the IC backprojecion first. Aborted.')
end
    
% Set the popupmenus for channels.
channelList = STUDY.clust2ch.channelList;
set(handles.channelToPlot, 'string', channelList);

% Set the popupmenus for STUDY.design.variable(1).
var1Label = STUDY.design(STUDY.currentdesign).variable(1).label;
var1Value = STUDY.design(STUDY.currentdesign).variable(1).value;
if isempty(var1Label)
    var1Strings = '(none)';
else
    for n = 1:length(var1Value)
        currentOutput = var1Value{n};
        if iscell(currentOutput)
            currentConditionLabelCell = currentOutput;
            currentOutput             = '';
            for combinedItemIdx = 1:length(currentConditionLabelCell)
                currentOutput = [currentOutput currentConditionLabelCell{combinedItemIdx}];
                if combinedItemIdx < length(currentConditionLabelCell)
                    currentOutput = [currentOutput '+'];
                end
            end
        end
        var1Strings{n} = [var1Label ': ' num2str(currentOutput)];
    end
end
set(handles.studyDesignVariable1Popupmenu, 'string', var1Strings);

% Set the popupmenus for STUDY.design.variable(2).
var2Label = STUDY.design(STUDY.currentdesign).variable(2).label;
var2Value = STUDY.design(STUDY.currentdesign).variable(2).value;
if isempty(var2Label)
    var2Strings = '(none)';
else
    for n = 1:length(var2Value)
        currentOutput = var2Value{n};
        if iscell(currentOutput)
            currentConditionLabelCell = currentOutput;
            currentOutput             = '';
            for combinedItemIdx = 1:length(currentConditionLabelCell)
                currentOutput = [currentOutput currentConditionLabelCell{combinedItemIdx}];
                if combinedItemIdx < length(currentConditionLabelCell)
                    currentOutput = [currentOutput '+'];
                end
            end
        end
        var2Strings{n} = [var2Label ': ' num2str(currentOutput)];
    end
end
set(handles.studyDesignVariable2Popupmenu, 'string', var2Strings);

% Choose default command line output for Figure1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Figure1 wait for user response (see UIRESUME)
% uiwait(handles.Figure1);
%handles.channelToPlot;

% --- Outputs from this function are returned to the command line.
function varargout = std_plot_clust2ch_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in ERP_or_Envelope.
function ERP_or_Envelope_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to ERP_or_Envelope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
currentSelection = contents{get(hObject,'Value')};
if strcmp(currentSelection, 'Grand-average ERP (with mean-within-a-cluster overlay)') | strcmp(currentSelection, 'Grand-average ERP (with subjects x clusters overlay)')
    set(handles.channelToPlot, 'Enable', 'on');
    set(handles.pvafDisplay,   'Enable', 'off');
    set(handles.baselineRange, 'Enable', 'on');
    set(handles.baselineRangeText, 'Enable', 'on');
else
    set(handles.channelToPlot, 'Enable', 'off');
    set(handles.baselineRange, 'Enable', 'off');
    set(handles.baselineRangeText, 'Enable', 'off');
end



% --- Executes during object creation, after setting all properties.
function ERP_or_Envelope_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to ERP_or_Envelope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plotRange_Callback(hObject, eventdata, handles)
% hObject    handle to plotRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotRange as text
%        str2double(get(hObject,'String')) returns contents of plotRange as a double
STUDY = evalin('base','STUDY');
latencyRangeValues = str2num(get(hObject,'String'));
minLatency = latencyRangeValues(1);
maxLatency = latencyRangeValues(2);
[~,minLatencyIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-minLatency));
[~,maxLatencyIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-maxLatency));
newString = num2str([STUDY.clust2ch.latencyInMillisecond(minLatencyIdx) STUDY.clust2ch.latencyInMillisecond(maxLatencyIdx)]);
set(hObject, 'String', newString);



% --- Executes during object creation, after setting all properties.
function plotRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
STUDY = evalin('base', 'STUDY');
defaultMinLatency = num2str(STUDY.clust2ch.latencyInMillisecond(1));
defaultMaxLatency = num2str(STUDY.clust2ch.latencyInMillisecond(end));
set(hObject, 'String', [defaultMinLatency ' ' defaultMaxLatency]);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in studyDesignVariable1Popupmenu.
function studyDesignVariable1Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to studyDesignVariable1Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns studyDesignVariable1Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from studyDesignVariable1Popupmenu



% --- Executes during object creation, after setting all properties.
function studyDesignVariable1Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to studyDesignVariable1Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
STUDY = evalin('base', 'STUDY');
if isfield(STUDY.clust2ch, 'withinSubjectCondition')
%         %here is the check code
%         %mergedWithinSubjectCondition   = STUDY.clust2ch.studyDesignVariable1Popupmenu;
%         %separateWithinSubjectCondition = mergedWithinSubjectCondition{1,1}; 
%         STUDY.clust2ch.studyDesignVariable1Popupmenu = mergedWithinSubjectCondition;
%         STUDY.clust2ch.studyDesignVariable1Popupmenu = separateWithinSubjectCondition;
    conditionList = STUDY.clust2ch.withinSubjectCondition;
    for n = 1:length(conditionList)
        if iscell(conditionList{1,n}) % conditions merged?
            % tmpCondition = strjoin(conditionList{1,n}, '&'); % DO NOT USE strjoin since this is heavily overloaded and tend to use the wrong one!
            tmpCell = conditionList{1,n};
            tmpCell(2,:) = {' & '};
            tmpCell{2,end} = '';
            tmpCondition = [tmpCell{:}];
        else
            tmpCondition = conditionList{1,n};
        end
        finalList{1,n} = tmpCondition; %#ok<*AGROW>
    end
    set(hObject, 'String', finalList);
    set(hObject, 'Enable', 'on');
else
    set(hObject, 'String', 'Single condition');
    set(hObject, 'Enable', 'off');
end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in betweenSubjectCondition.
function betweenSubjectCondition_Callback(hObject, eventdata, handles)
% hObject    handle to betweenSubjectCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns betweenSubjectCondition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from betweenSubjectCondition



% --- Executes during object creation, after setting all properties.
function betweenSubjectCondition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betweenSubjectCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
STUDY = evalin('base', 'STUDY');
if isfield(STUDY.clust2ch, 'betweenSubjectCondition')
%         %here is the check code
%         %mergedGroupLevels   = STUDY.clust2ch.betweenSubjectCondition;
%         %separateGroupLevels = mergedGroupLevels{1,1}; 
%         STUDY.clust2ch.betweenSubjectCondition = mergedGroupLevels;
%         STUDY.clust2ch.betweenSubjectCondition = separateGroupLevels;
    conditionList = STUDY.clust2ch.betweenSubjectCondition;
    for n = 1:length(conditionList)
        if iscell(conditionList{1,n}) % conditions merged?
            % tmpCondition = strjoin(conditionList{1,n}, '&'); % AVOID strjoin!
            tmpCell = conditionList{1,n};
            tmpCell(2,:) = {' & '};
            tmpCell{2,end} = '';
            tmpCondition = [tmpCell{:}];
        else
            tmpCondition = conditionList{1,n};
        end
        finalList{1,n} = tmpCondition;
    end
    set(hObject, 'String', finalList);
else
    set(hObject, 'String', 'Single group');
    set(hObject, 'Enable', 'off');
end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelToPlot.
function channelToPlot_Callback(hObject, eventdata, handles)
% hObject    handle to channelToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channelToPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelToPlot



% --- Executes during object creation, after setting all properties.
function channelToPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
channelList = evalin('base', 'STUDY.clust2ch.channelList');
set(hObject, 'String', channelList);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function baselineRange_Callback(hObject, eventdata, handles)
% hObject    handle to baselineRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineRange as text
%        str2double(get(hObject,'String')) returns contents of baselineRange as a double
STUDY = evalin('base','STUDY');
latencyRangeValues = str2num(get(hObject,'String'));
minLatency = latencyRangeValues(1);
maxLatency = latencyRangeValues(2);
[~,minLatencyIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-minLatency));
[~,maxLatencyIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-maxLatency));
newString = num2str([STUDY.clust2ch.latencyInMillisecond(minLatencyIdx) STUDY.clust2ch.latencyInMillisecond(maxLatencyIdx)]);
set(hObject, 'String', newString);



% --- Executes during object creation, after setting all properties.
function baselineRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

STUDY = evalin('base','STUDY');
latency = STUDY.clust2ch.latencyInMillisecond;
negativeLatencyIdx = find(latency<=0);
if any(negativeLatencyIdx)
    baselineRange = [latency(negativeLatencyIdx(1)) latency(negativeLatencyIdx(end))];
else
    baselineRange = [latency(1) latency(end)];
end
set(hObject, 'String', num2str(baselineRange));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lowPassFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ERP_or_Envelope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lowPassFilter_Callback(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text as text
%        str2double(get(hObject,'String')) returns contents of text as a double



% --- Executes during object creation, after setting all properties.
function text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'String', '');

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% use eegfiltnew()
function smoothdata = myeegfilt(data, srate, locutoff, hicutoff)
disp('Applying low pass filter (Hamming).')
disp('Transition band width is the half of the passband edge frequency.')
tmpFiltData.data   = data;
tmpFiltData.srate  = srate;
tmpFiltData.trials = 1;
tmpFiltData.event  = [];
tmpFiltData.pnts   = length(data);
filtorder = pop_firwsord('hamming', srate, hicutoff/2);
tmpFiltData_done   = pop_eegfiltnew(tmpFiltData, locutoff, hicutoff, filtorder);
smoothdata         = tmpFiltData_done.data;


% --- Executes on selection change in studyDesignVariable2Popupmenu.
function studyDesignVariable2Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to studyDesignVariable2Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns studyDesignVariable2Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from studyDesignVariable2Popupmenu


% --- Executes during object creation, after setting all properties.
function studyDesignVariable2Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to studyDesignVariable2Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sessionPopupmenu.
function sessionPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to sessionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sessionPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sessionPopupmenu


% --- Executes during object creation, after setting all properties.
function sessionPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sessionPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotPushbutton.
function plotPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toggleMode = 0; % 0-normal, 1-LEFT, 2-RIGHT. For the Max-Planck collaboration.

ALLEEG = evalin('base', 'ALLEEG');
STUDY  = evalin('base', 'STUDY');

% Obtain user-specified plot range.
tmpPlotRange = str2num(get(handles.plotRange, 'String')); %#ok<*ST2NM>
[~,plotMinFrameIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-tmpPlotRange(1,1)));
[~,plotMaxFrameIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-tmpPlotRange(1,2)));

% Obtain user-specified PVAF range.
tmpPvafRange = str2num(get(handles.analysisWindowEdit, 'String')); %#ok<*ST2NM>
[~,pvafMinFrameIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-tmpPvafRange(1,1)));
[~,pvafMaxFrameIdx] = min(abs(STUDY.clust2ch.latencyInMillisecond-tmpPvafRange(1,2)));

% Obtain user-specified baseline range.
baselineRange = str2num(get(handles.baselineRange,'String'));
minBaseIdx = find(STUDY.clust2ch.latencyInMillisecond>=baselineRange(1,1), 1, 'first');
maxBaseIdx = find(STUDY.clust2ch.latencyInMillisecond<=baselineRange(1,2), 1, 'last');

% Obtain the main data table.
mainDataTable = STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition;

% Extract the selected group.
var1Label = STUDY.design(STUDY.currentdesign).variable(1).label;
var2Label = STUDY.design(STUDY.currentdesign).variable(2).label;
if     strcmp(lower(var1Label), 'group') 
    currentConditionIdx = get(handles.studyDesignVariable1Popupmenu, 'value');
    uniqueConditionLable = unique(mainDataTable(:,2));
    groupSessionSelectedSubjIdx = find(strcmp(mainDataTable(:,2), uniqueConditionLable(currentConditionIdx)));
elseif strcmp(lower(var2Label), 'group')
    currentConditionIdx = get(handles.studyDesignVariable2Popupmenu, 'value');
    uniqueConditionLable = unique(mainDataTable(:,2));
    groupSessionSelectedSubjIdx = find(strcmp(mainDataTable(:,2), uniqueConditionLable(currentConditionIdx)));
elseif strcmp(lower(var1Label), 'session')
    currentConditionIdx = get(handles.studyDesignVariable1Popupmenu, 'value');
    uniqueConditionLable = unique(mainDataTable(:,3));
    groupSessionSelectedSubjIdx = find(strcmp(mainDataTable(:,3), uniqueConditionLable(currentConditionIdx)));
elseif strcmp(lower(var2Label), 'session')
    currentConditionIdx = get(handles.studyDesignVariable2Popupmenu, 'value');
    uniqueConditionLable = unique(mainDataTable(:,3));
    groupSessionSelectedSubjIdx = find(strcmp(mainDataTable(:,3), uniqueConditionLable(currentConditionIdx)));
else
    currentConditionIdx = 1; % Default value.
    groupSessionSelectedSubjIdx = 1:size(mainDataTable,1);
end


% Extract the selected condition and ICs.
guiSelectedChannelIdx = get(handles.channelToPlot, 'value');
currentChannelLabel   = STUDY.clust2ch.channelList{guiSelectedChannelIdx};
if     ~strcmp(var1Label, 'group') & ~strcmp(var1Label, 'session')
    currentWithinSubjectCondition = get(handles.studyDesignVariable1Popupmenu, 'value');
elseif ~strcmp(var2Label, 'group') & ~strcmp(var2Label, 'session')
    currentWithinSubjectCondition = get(handles.studyDesignVariable2Popupmenu, 'value');
elseif (strcmp(var1Label, 'group') | strcmp(var1Label, 'session')) & strcmp(var2Label, 'group') | strcmp(var2Label, 'session')
    error('Two across-subject condition design not supported yet.')
end

% Obtain total and selective backprojections on the selected channel.
allChannelAllIcBackproj      = zeros(length(STUDY.clust2ch.channelList), size(mainDataTable{1,5},2), length(groupSessionSelectedSubjIdx));
allChannelSelectedIcBackproj = zeros(length(STUDY.clust2ch.channelList), size(mainDataTable{1,5},2), length(groupSessionSelectedSubjIdx));
for subjIdx = 1:length(groupSessionSelectedSubjIdx)
    
    % Obtain the current subject's index in the main data table.
    currentSubjIdx = groupSessionSelectedSubjIdx(subjIdx);
           
    % Obtain the current subject's EEG.icaact.
    currentIcaact = mainDataTable{currentSubjIdx,5};
    
    % Obtain the current subject's ICs selected.
    currentIcIdx  = mainDataTable{currentSubjIdx,4};
    
    % Obtain the current subject's EEG.icawinv.
    currentAlleegIdx = mainDataTable{currentSubjIdx,1};
    currentIcawinv   = ALLEEG(1,currentAlleegIdx).icawinv;
    
    if toggleMode == 0
        % Compute the current subject's total back projection.
        allChannelAllIcBackproj(:,:,subjIdx)      = double(currentIcawinv(:,:           )) * double(currentIcaact(:,           :,currentWithinSubjectCondition));
        allChannelSelectedIcBackproj(:,:,subjIdx) = double(currentIcawinv(:,currentIcIdx)) * double(currentIcaact(currentIcIdx,:,currentWithinSubjectCondition));
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Optional idea: For the case of subtractions between conditions, comment out the previous 3 lines and use this custome code. 11/16/2018 Makoto.%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compute the current subject's total back projection for all conditions.
        allChannelAllIcBackproj1(:,:)      = double(currentIcawinv(:,:           )) * double(currentIcaact(:,           :,1));
        allChannelSelectedIcBackproj1(:,:) = double(currentIcawinv(:,currentIcIdx)) * double(currentIcaact(currentIcIdx,:,1));
        allChannelAllIcBackproj2(:,:)      = double(currentIcawinv(:,:           )) * double(currentIcaact(:,           :,2));
        allChannelSelectedIcBackproj2(:,:) = double(currentIcawinv(:,currentIcIdx)) * double(currentIcaact(currentIcIdx,:,2));
        allChannelAllIcBackproj3(:,:)      = double(currentIcawinv(:,:           )) * double(currentIcaact(:,           :,3));
        allChannelSelectedIcBackproj3(:,:) = double(currentIcawinv(:,currentIcIdx)) * double(currentIcaact(currentIcIdx,:,3));
        allChannelAllIcBackproj4(:,:)      = double(currentIcawinv(:,:           )) * double(currentIcaact(:,           :,4));
        allChannelSelectedIcBackproj4(:,:) = double(currentIcawinv(:,currentIcIdx)) * double(currentIcaact(currentIcIdx,:,4));
        
        % Perform subtraction across conditions.
        allChannelAllIcBackproj(:,:,subjIdx)      = (allChannelAllIcBackproj2 - allChannelAllIcBackproj4) - (allChannelAllIcBackproj1 - allChannelAllIcBackproj3);
        allChannelSelectedIcBackproj(:,:,subjIdx) = (allChannelSelectedIcBackproj2 - allChannelSelectedIcBackproj4) - (allChannelSelectedIcBackproj1 - allChannelSelectedIcBackproj3);
    end
end

% Perform low-pass filter if requested.
if any(get(handles.lowPassFilter, 'String'))
    passbandEdge = str2num(get(handles.lowPassFilter, 'String'));
    srate = evalin('base', 'ALLEEG(1,1).srate');
    allChannelAllIcBackproj      = myeegfilt(allChannelAllIcBackproj,      srate, 0, passbandEdge);
    allChannelSelectedIcBackproj = myeegfilt(allChannelSelectedIcBackproj, srate, 0, passbandEdge);
end

% Perform baseline correction.
allChannelAllIcBackproj      = bsxfun(@minus, allChannelAllIcBackproj,      mean(allChannelAllIcBackproj(:,      minBaseIdx:maxBaseIdx,:),2));
allChannelSelectedIcBackproj = bsxfun(@minus, allChannelSelectedIcBackproj, mean(allChannelSelectedIcBackproj(:, minBaseIdx:maxBaseIdx,:),2));

% Compute either PPAF or AUC.
allChannelAllIcBackprojWindow      = allChannelAllIcBackproj(:,pvafMinFrameIdx:pvafMaxFrameIdx,:);
allChannelSelectedIcBackprojWindow = allChannelSelectedIcBackproj(:,pvafMinFrameIdx:pvafMaxFrameIdx,:);
diffMatrixWindow                   = allChannelAllIcBackprojWindow-allChannelSelectedIcBackprojWindow;
switch get(handles.chooseMeasurepopupmenu, 'Value')
    case 1 % Compute percent variance accounted for (PVAF).
        selectedMeasureList = squeeze(100-100*(var(diffMatrixWindow, [], 2))./var(allChannelAllIcBackprojWindow, [], 2));   
    case 2 % Compute percent power accounted for (PPAF).
        selectedMeasureList = squeeze(100-100*(mean(diffMatrixWindow.^2, 2))./mean(allChannelAllIcBackprojWindow.^2, 2));
    case 3 % Compute area under a curve (AUC). This is good for testing a window that includes non-fluctruating waveform, such as P300 peak.
        selectedMeasureList = squeeze(100*trapz(allChannelSelectedIcBackprojWindow,2)./trapz(allChannelAllIcBackprojWindow,2)); % https://www.mathworks.com/matlabcentral/answers/154089-area-under-curve-no-function
end
        
        % The code below is depricated after the discussion with Scott and Arno about the difference between PVAF and PPAF. 09/13/2018
        %
        % % Compute either PVAF or AUC.
        % allChannelAllIcBackprojWindow      = allChannelAllIcBackproj(:,pvafMinFrameIdx:pvafMaxFrameIdx,:);
        % allChannelSelectedIcBackprojWindow = allChannelSelectedIcBackproj(:,pvafMinFrameIdx:pvafMaxFrameIdx,:);
        % diffMatrixWindow                   = allChannelAllIcBackprojWindow-allChannelSelectedIcBackprojWindow;
        % switch get(handles.chooseMeasurepopupmenu, 'Value')
        %     case 1 % Compute percent variance accounted for (PVAF).
        %                 diffAc = var(diffMatrixWindow,0,2);
        %                 diffDc = mean(diffMatrixWindow,2).^2;
        %                 allAc  = var(allChannelAllIcBackprojWindow,0,2);
        %                 allDc  = mean(allChannelAllIcBackprojWindow,2).^2;
        %                 selectedMeasureList = squeeze(100-100*(diffAc+diffDc)./(allAc+allDc));
        %             %selectedMeasureList = squeeze(100-100*var(diffMatrixWindow,0,2)./var(allChannelAllIcBackprojWindow,0,2)); % This PVAF for envtopo() does NOT count DC. 07/27/2018 Makoto.
        %     case 2 % Compute area under a curve (AUC). This is good for testing a window that includes non-fluctruating waveform, such as P300 peak.
        %         selectedMeasureList = squeeze(100*trapz(allChannelSelectedIcBackprojWindow,2)./trapz(allChannelAllIcBackprojWindow,2)); % https://www.mathworks.com/matlabcentral/answers/154089-area-under-curve-no-function
        % end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot PVAF/AUC topo. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
allMeasureLabels     = get(handles.chooseMeasurepopupmenu, 'String');
switch get(handles.chooseMeasurepopupmenu, 'value')
    case 1
        selectedMeasureLabel = 'PVAF';
    case 2
        selectedMeasureLabel = 'PPAF';
    case 3
        selectedMeasureLabel = 'AUC';
end

groupMeanPvaf = mean(selectedMeasureList,2);
cla(handles.pvafTopoAxes)
axes(handles.pvafTopoAxes)

switch toggleMode
    case 0
        currentChannelIdx    = find(strcmp({ALLEEG(1,currentAlleegIdx).chanlocs.labels}, currentChannelLabel));
    case 1
        currentChannelLabel = {'P1' 'P3' 'P5' 'P7' 'PO3' 'PO7' 'O1'}; % 'LEFT'
        currentChannelIdx   = sort(cell2mat(cellfun(@(x) find(strcmp({ALLEEG(1,currentAlleegIdx).chanlocs.labels}, x)), currentChannelLabel, 'uniformoutput', false)));
        guiSelectedChannelIdx = currentChannelIdx;
    case 2
        currentChannelLabel = {'P2' 'P4' 'P6' 'P8' 'PO4' 'PO8' 'O2'}; % 'RIGHT'
        currentChannelIdx   = sort(cell2mat(cellfun(@(x) find(strcmp({ALLEEG(1,currentAlleegIdx).chanlocs.labels}, x)), currentChannelLabel, 'uniformoutput', false)));
        guiSelectedChannelIdx = currentChannelIdx;
end

topoplotHandle = topoplot(groupMeanPvaf, ALLEEG(1,1).chanlocs, 'emarker2', {currentChannelIdx, 'o', 'k', 8, 1});
colorbarHandle = colorbar;
set(get(colorbarHandle, 'title'), 'string', selectedMeasureLabel, 'fontsize', 16);
set(colorbarHandle, 'fontsize', 16);
set(gcf, 'color', [0.66 0.76 1]);



%%%%%%%%%%%%%%%%%
%%% Plot ERP. %%%
%%%%%%%%%%%%%%%%%
% Obtain single-channel projections for all subjects. mean() is computed in case multiple channels should be used by custom code.
selectedChAllIcBackproj      = squeeze(mean(allChannelAllIcBackproj(guiSelectedChannelIdx,:,:),1));
selectedChSelectedIcBackproj = squeeze(mean(allChannelSelectedIcBackproj(guiSelectedChannelIdx,:,:),1));

% Obtain single-channel measure for all subjects.
selectedChMeasureList = selectedMeasureList (guiSelectedChannelIdx,:);
meanMeasure           = mean(mean(selectedChMeasureList)); % Mean is used in case multiple channels are specified by custom code. 11/16/2018 Makoto.
stdMeasure            = std(mean(selectedChMeasureList,1));
seMeasure             = stdMeasure/sqrt(size(selectedChMeasureList,2));

% Clear the existing plot.
cla(handles.mainPlotWindow);

% Plot ERP time series.
plotLatency            = STUDY.clust2ch.latencyInMillisecond(plotMinFrameIdx:plotMaxFrameIdx);
allIcBackprojPlot      = selectedChAllIcBackproj(plotMinFrameIdx:plotMaxFrameIdx,:);
selectedIcBackprojPlot = selectedChSelectedIcBackproj(plotMinFrameIdx:plotMaxFrameIdx,:);
hold(handles.mainPlotWindow, 'on')
plot(handles.mainPlotWindow, plotLatency, allIcBackprojPlot,      'LineWidth', 0.5, 'Color', [0.66 0.66 0.96]);
plot(handles.mainPlotWindow, plotLatency, selectedIcBackprojPlot, 'LineWidth', 0.5, 'Color', [0.96 0.66 0.66]);
erpHandle1 = plot(handles.mainPlotWindow, plotLatency, mean(allIcBackprojPlot,2),      'LineWidth', 3.0, 'Color', [0.32 0.32 0.96]);
erpHandle2 = plot(handles.mainPlotWindow, plotLatency, mean(selectedIcBackprojPlot,2), 'LineWidth', 3.0, 'Color', [0.96 0.32 0.32]);
%legend(handles.mainPlotWindow, {currentChannelLabel ['IC projection to ' currentChannelLabel]})
xlabel(handles.mainPlotWindow, 'Latency (ms)')
ylabel(handles.mainPlotWindow, 'Amplitude (microV)')

% Compute ylim.
plotMin    = min([allIcBackprojPlot(:); selectedIcBackprojPlot(:)]);
plotMax    = max([allIcBackprojPlot(:); selectedIcBackprojPlot(:)]);
plotMargin = (plotMax - plotMin)*0.01;
plotMin    = plotMin-plotMargin;
plotMax    = plotMax+plotMargin;

% Plot background fill to indicate PVAF window.
aucLatency = STUDY.clust2ch.latencyInMillisecond(pvafMinFrameIdx:pvafMaxFrameIdx);
X = [aucLatency,fliplr(aucLatency)];
Y = [repmat(plotMax, [1 length(aucLatency)]) repmat(plotMin, [1 length(aucLatency)])];
fillHandle = fill(X,Y,[0.93 0.93 0.93], 'Edgecolor', [1 1 1], 'Parent', handles.mainPlotWindow);
uistack(fillHandle, 'bottom')



% Add legend. 
switch toggleMode
    case 0
        legend([erpHandle1 erpHandle2], {currentChannelLabel ['IC projection to ' currentChannelLabel]})
    case 1
        legend([erpHandle1 erpHandle2], {'LEFT channels' 'IC projections to LEFT'})
    case 2
        legend([erpHandle1 erpHandle2], {'RIGHT channels' 'IC projections to RIGHT'})
end
hold(handles.mainPlotWindow, 'off')



% Apply ylim to the plot.
ylim(handles.mainPlotWindow, [plotMin plotMax])

% Display the results.
alleegIdx_icIdx_clustIdx_groupSession = STUDY.clust2ch.alleegIdx_icIdx_clustIdx_groupSession;
selectedClusterIdx = unique(alleegIdx_icIdx_clustIdx_groupSession(:,3));
str1 = sprintf('%.0f subjects, %.0f ICs', length(groupSessionSelectedSubjIdx), sum(STUDY.clust2ch.alleegIdx_icIdx_clustIdx_groupSession(:,4)==currentConditionIdx));
clusterIdxStr = '';
for clusterIdx = 1:length(selectedClusterIdx)
    clusterIdxStr = [clusterIdxStr num2str(selectedClusterIdx(clusterIdx))];
    if clusterIdx < length(selectedClusterIdx)
        clusterIdxStr = [clusterIdxStr ' & '];
    end
end
switch toggleMode
    case 0
        str2 = sprintf('Cluster %s explains %.1f%% of %s (across-subject SD %.1f, SE %.1f) of %s', clusterIdxStr, meanMeasure, selectedMeasureLabel, stdMeasure, seMeasure, currentChannelLabel);
    case 1
        str2 = sprintf('Cluster %s explains %.1f%% of %s (across-subject SD %.1f, SE %.1f) of %s', clusterIdxStr, meanMeasure, selectedMeasureLabel, stdMeasure, seMeasure, 'LEFT');
    case 2
        str2 = sprintf('Cluster %s explains %.1f%% of %s (across-subject SD %.1f, SE %.1f) of %s', clusterIdxStr, meanMeasure, selectedMeasureLabel, stdMeasure, seMeasure, 'RIGHT');
end
set(handles.numSubjectIcText, 'string', str1, 'fontsize', 16)
set(handles.pvafText, 'string', str2, 'fontsize', 16)

% Set the font size.
set(findall(handles.mainPlotWindow, '-property', 'fontsize'), 'fontsize', 16)



function analysisWindowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to analysisWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of analysisWindowEdit as text
%        str2double(get(hObject,'String')) returns contents of analysisWindowEdit as a double


% --- Executes during object creation, after setting all properties.
function analysisWindowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analysisWindowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

STUDY = evalin('base', 'STUDY');
defaultMinLatency = num2str(STUDY.clust2ch.latencyInMillisecond(1));
defaultMaxLatency = num2str(STUDY.clust2ch.latencyInMillisecond(end));
set(hObject, 'String', [defaultMinLatency ' ' defaultMaxLatency]);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in whiteBackgroundCheckbox.
function whiteBackgroundCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to whiteBackgroundCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of whiteBackgroundCheckbox
if get(handles.whiteBackgroundCheckbox, 'Value') == 1
    set(gcf, 'color', [1 1 1]);
    set(findall(gcf, 'Style', 'text'), 'Backgroundcolor', [1 1 1]);
    set(handles.whiteBackgroundCheckbox, 'Backgroundcolor', [1 1 1]);
else
    set(gcf, 'color', [0.66 0.76 1]);
    set(findall(gcf, 'Style', 'text'), 'Backgroundcolor', [0.66 0.76 1]);
    set(handles.whiteBackgroundCheckbox, 'Backgroundcolor', [0.66 0.76 1]);    
end


% --- Executes on selection change in chooseMeasurepopupmenu.
function chooseMeasurepopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to chooseMeasurepopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseMeasurepopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseMeasurepopupmenu


% --- Executes during object creation, after setting all properties.
function chooseMeasurepopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseMeasurepopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when Figure1 is resized.
function Figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to Figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
