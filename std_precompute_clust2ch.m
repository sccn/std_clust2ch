% std_precompute_clust2ch() - Loads each subject (i.e., ALLEEG .set files),
%                             obtain their EEG.icaact, and store them under
%                             STUDY.clust2ch.

% Author: Makoto Miyakoshi, JSPS/SCCN,INC,UCSD
% History
% 05/07/2019 Makoto. Debugged. Obtaining unique conditions across subjects across whom within-subject conditions are separated by subjects (i.e., 'session' registered as different subject). This only works when only var1 is used. This nichey update is for Kelly Michaelis.
% 04/20/2019 Makoto. Debugged. elseif length(EEG.epoch(epochIdx).eventlatency) == 1; % If there is only one event per epoch.
% 11/16/2018 Makoto. Debugged for the case of using something other than 'type' to specify single-trial conditions.
% 09/22/2018 Makoto. Debugged for the case of backprojecting continuous data with no conditions.
% 09/17/2018 Makoto. Debugged for the case of combined conditions. Thanks Lizzy Blundon!
% 07/25/2018 Makoto. Developed into std_clust2ch.
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



function varargout = std_precompute_clust2ch(varargin)
% STD_PRECOMPUTE_CLUST2CH MATLAB code for std_precompute_clust2ch.fig
%      STD_PRECOMPUTE_CLUST2CH, by itself, creates a new STD_PRECOMPUTE_CLUST2CH or raises the existing
%      singleton*.
%
%      H = STD_PRECOMPUTE_CLUST2CH returns the handle to a new STD_PRECOMPUTE_CLUST2CH or the handle to
%      the existing singleton*.
%
%      STD_PRECOMPUTE_CLUST2CH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STD_PRECOMPUTE_CLUST2CH.M with the given input arguments.
%
%      STD_PRECOMPUTE_CLUST2CH('Property','Value',...) creates a new STD_PRECOMPUTE_CLUST2CH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before std_precompute_clust2ch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to std_precompute_clust2ch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help std_precompute_clust2ch

% Last Modified by GUIDE v2.5 25-Jul-2018 18:09:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @std_precompute_clust2ch_OpeningFcn, ...
                   'gui_OutputFcn',  @std_precompute_clust2ch_OutputFcn, ...
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


% --- Executes just before std_precompute_clust2ch is made visible.
function std_precompute_clust2ch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to std_precompute_clust2ch (see VARARGIN)

% Choose default command line output for std_precompute_clust2ch
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes std_precompute_clust2ch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = std_precompute_clust2ch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function includingClusterIdxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to includingClusterIdxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of includingClusterIdxEdit as text
%        str2double(get(hObject,'String')) returns contents of includingClusterIdxEdit as a double


% --- Executes during object creation, after setting all properties.
function includingClusterIdxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to includingClusterIdxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savePathPushbutton.
function savePathPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savePathPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% launch GUI to obtain directory
targetDirectory = uigetdir;
if any(targetDirectory)
    set(handles.savePathEdit, 'String', targetDirectory);
end


% --- Executes on button press in skipToStoreDataCheckbox.
function skipToStoreDataCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to skipToStoreDataCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skipToStoreDataCheckbox


function savePathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to savePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savePathEdit as text
%        str2double(get(hObject,'String')) returns contents of savePathEdit as a double


% --- Executes during object creation, after setting all properties.
function savePathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function excludingClusterIdxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to excludingClusterIdxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of excludingClusterIdxEdit as text
%        str2double(get(hObject,'String')) returns contents of excludingClusterIdxEdit as a double


% --- Executes during object creation, after setting all properties.
function excludingClusterIdxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excludingClusterIdxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in helpPushbutton.
function helpPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pophelp('std_selectICsByCluster.m')


% --- Executes on button press in excludingClusterCheckbox.
function excludingClusterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to excludingClusterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excludingClusterCheckbox


% --- Executes on button press in startPushbutton.
function startPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ALLEEG   = evalin('base', 'ALLEEG');
EEG      = evalin('base', 'EEG');
STUDY    = evalin('base', 'STUDY');
if get(handles.excludingClusterCheckbox, 'Value');
    excludingClusterIdx = str2num(get(handles.includingClusterIdxEdit, 'String'));
    if strcmp(STUDY.cluster(2).name, 'outlier 2')
        includingClusterIdx = setdiff(3:length(STUDY.cluster), excludingClusterIdx);
    else
        includingClusterIdx = setdiff(2:length(STUDY.cluster), excludingClusterIdx);
    end
else
    includingClusterIdx = str2num(get(handles.includingClusterIdxEdit, 'String'));
end
excludingClusterFromPvafIdx   = str2num(get(handles.excludingClusterIdxEdit, 'String'));
savePath                      = get(handles.savePathEdit, 'String');



    % Functions are now merged. 07/25/2018 Makoto.
    %
    % std_selectICsByCluster(STUDY, ALLEEG, EEG, includingClusterIdx, excludingClusterFromPvafIdx, savePath); % It will 'assign in' so no outputs.
    % function std_selectICsByCluster(STUDY, ALLEEG, EEG, includingClusterIdx, excludingClusterFromPvafIdx, savePath)

    
    
%%%%%%%%%%%%%%%%%%%
%%% input check %%%
%%%%%%%%%%%%%%%%%%%
if isempty(includingClusterIdx)
    error('Enter the cluster numbers to selectICsByClusterect.')
end

if isempty(savePath)
    disp('No save path provided: New .set files will NOT be created.')
else
    disp(['Save path provided: New .set files will be created under ' savePath])
end

% Check data dimensions.
if size(ALLEEG(1,1).data)==2
    error('EEG data must be epoched.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Obtain cluster indices to include and exclude. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain cluster indices to include and exclude.
if isempty(excludingClusterFromPvafIdx)
    excludingClusterFromPvafIdx = 0;
end
clustUse = nonzeros([includingClusterIdx excludingClusterFromPvafIdx])';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Find common channels available across all subjects. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skip this process when save path is specified. (05/27/2016 Makoto)
if isempty(savePath)
    for uniqueSubjIdx = 1:length(ALLEEG)-1
        if uniqueSubjIdx == 1
            commonChanList = {ALLEEG(1,uniqueSubjIdx).chanlocs.labels};
        end
        currentChanList = {ALLEEG(1,uniqueSubjIdx+1).chanlocs.labels};
        commonChanList  = intersect(commonChanList, currentChanList);
        if isempty(commonChanList)
            error('No common channel!')
        end
    end
    disp(sprintf('%d channels are commonly available across all datasets.',length(commonChanList)))
    clear currentChanList

    % Obtain the original channel order because commonChanList is SORTED: find the dataset that has the most channels.
    for uniqueSubjIdx = 1:length(ALLEEG)
        numChanList(uniqueSubjIdx,1) = length(ALLEEG(1,uniqueSubjIdx).chanlocs);
    end
    [~,maxChanSetIdx] = max(numChanList);
    largestChanlocs = ALLEEG(1,maxChanSetIdx).chanlocs;
    mostChanList = {largestChanlocs.labels};
    
    survivedChanIdx = ismember(mostChanList, commonChanList);
    selectICsByClusterChan = mostChanList(1,survivedChanIdx);
    clear commonChanList commonChan largestChanlocs maxChanSetIdx mostChanList numChanList
else
    selectICsByClusterChan = 'noChannelSelected';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Delete old STUDY.selectICsByCluster variables. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(STUDY, 'selectICsByCluster')
    STUDY = rmfield(STUDY, 'selectICsByCluster');
    disp('Old STUDY.selectICsByCluster is deleted for new results.')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Delete old STUDY.clust2ch variables. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(STUDY, 'clust2ch')
    STUDY = rmfield(STUDY, 'clust2ch');
    disp('Old STUDY.clust2ch is deleted for new results.')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create subj & IC list: no group or session. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
designLabel = {STUDY.design(STUDY.currentdesign).variable.label};
groupFieldIdx = find(strcmp(designLabel, 'group')|strcmp(designLabel, 'session'));
if isempty(groupFieldIdx)
    
    % Pre-allocate memory (05/07/2019 updated)
    perGroupLength = 0;
    for clustIdx = 2:length(STUDY.cluster)
        for conditionIdx = 1:size(STUDY.cluster(1,2).setinds,1)
            tmpLength = length(STUDY.cluster(1,clustIdx).setinds{conditionIdx,1});
            perGroupLength = perGroupLength + tmpLength;
        end
    end
    
    % Extract indices for setfiles and ICs. (05/07/2019 updated)
    allSetIc = zeros(perGroupLength, 3);
    listCounter = 0;
    for clustIdx = 2:length(STUDY.cluster)
        for conditionIdx = 1:size(STUDY.cluster(1,clustIdx).setinds,1)
            tmpSetInd = STUDY.cluster(1,clustIdx).setinds{conditionIdx,1};
            for m = 1:length(tmpSetInd)
                listCounter = listCounter+1;
                allSetIc(listCounter,1) = STUDY.design(STUDY.currentdesign).cell(tmpSetInd(1,m)).dataset; %#ok<*AGROW> % dataset number
                allSetIc(listCounter,2) = STUDY.cluster(1,clustIdx).allinds{conditionIdx,1}(1,m); % IC number
                allSetIc(listCounter,3) = clustIdx; % cluster number
            end
            
        end
    end
    
    % Sort the results into the order of the setfile index.
    tmpSetInd     = allSetIc(:,1);
    [~,sortIndex] = sort(tmpSetInd);
    allIcList = [allSetIc(sortIndex,:) repmat(1, [length(tmpSetInd) 1])]; % allSetIc_sorted == [subjID IC cluster group];
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create subj & IC list: with group or session. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    % detect 'group' or 'session' in the STUDY.design.variable
    STUDY.clust2ch.betweenSubjectCondition = STUDY.design(STUDY.currentdesign).variable(1,groupFieldIdx).value;
    
    % pre-allocate memory: one cannot use length(STUDY.group) because they may be combined by user
    if groupFieldIdx == 1
        combinedGroupValue = STUDY.design(STUDY.currentdesign).variable(1,1).value;
    else
        combinedGroupValue = STUDY.design(STUDY.currentdesign).variable(1,2).value;
    end
    perGroupLength = zeros(1, length(combinedGroupValue));
    
    for group = 1:length(combinedGroupValue)
        for clustIdx = 1:length(clustUse)
            switch groupFieldIdx
                case 1
                    tmpLength = length(STUDY.cluster(1,clustUse(clustIdx)).setinds{group,1});
                case 2
                    tmpLength = length(STUDY.cluster(1,clustUse(clustIdx)).setinds{1,group});
            end
            perGroupLength(1,group) = perGroupLength(1,group) + tmpLength;
        end
    end
    for group = 1:length(combinedGroupValue)
        allSetIc{1,group} = zeros(perGroupLength(1,group), 3);
    end
    
    % extract indices for ALL ICs included
    for group = 1:length(combinedGroupValue)
        listCounter = 0;
        for clustIdx = 2:length(STUDY.cluster) % skip the Parent cluster
            switch groupFieldIdx
                case 1
                    tmpSetInd = STUDY.cluster(1,clustIdx).setinds{group,1};
                case 2
                    tmpSetInd = STUDY.cluster(1,clustIdx).setinds{1,group};
            end
            for m = 1:length(tmpSetInd)
                listCounter = listCounter+1;
                allSetIc{1,group}(listCounter,1) = STUDY.design(STUDY.currentdesign).cell(tmpSetInd(m)).dataset; %#ok<*AGROW> % dataset number
                switch groupFieldIdx
                    case 1
                        allSetIc{1,group}(listCounter,2) = STUDY.cluster(1,clustIdx).allinds{group,1}(1,m); % IC number
                    case 2
                        allSetIc{1,group}(listCounter,2) = STUDY.cluster(1,clustIdx).allinds{1,group}(1,m); % IC number
                end
                allSetIc{1,group}(listCounter,3) = clustIdx; % cluster number
            end
        end
    end
    for group = 1:length(combinedGroupValue)
        tmpSetInd    = allSetIc{1,group}(:,1);
        [~,sortIndex] = sort(tmpSetInd);
        allSetIc{1,group} = allSetIc{1,group}(sortIndex,:);
        tmpList = [allSetIc{1,group} repmat(group, [length(allSetIc{1,group}) 1])];
        % allSetIc_sorted == [subjID IC cluster group];
        if group == 1
            allIcList = tmpList;
        else
            allIcList = [allIcList; tmpList];
        end
    end
    clear allSetIc
end
STUDY.clust2ch.allIcList = allIcList;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate unique subjects. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
includeIcIdx  = find(ismember(allIcList(:,3),includingClusterIdx));
alleegIdx_icIdx_clustIdx_groupSession = allIcList(includeIcIdx,:);
STUDY.clust2ch.alleegIdx_icIdx_clustIdx_groupSession = alleegIdx_icIdx_clustIdx_groupSession;

if any(excludingClusterFromPvafIdx)
    excludeIcSubjIdx = find(ismember(allIcList(:,3),excludingClusterFromPvafIdx));
    excludeIcList    = allIcList(excludeIcSubjIdx,:);
    STUDY.clust2ch.excludeIcList = excludeIcList;
end
clear excludeIcIdx

[~,uniqueSubjIdx] = unique(alleegIdx_icIdx_clustIdx_groupSession(:,1));
uniqueSubj = alleegIdx_icIdx_clustIdx_groupSession(uniqueSubjIdx,:);
uniqueSubj = uniqueSubj(:,[1 3]); % uniquesubj = [setfileIdx clusterIdx]
STUDY.clust2ch.subjectList   = {ALLEEG(uniqueSubj(:,1)).setname}';
STUDY.clust2ch.latencyInMillisecond = ALLEEG(1,1).times;
if any(groupFieldIdx)
    STUDY.clust2ch.groupList = alleegIdx_icIdx_clustIdx_groupSession(uniqueSubjIdx,4);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Process each subject. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
waitBarHandle = waitbar(0,'Selecting ICs...');
waitBarCount  = 0;

% Check STUDY variables.
withinSubjectConditionPresent = [any(designLabel{1,1}) & ~(strcmp(designLabel{1,1},'group')|strcmp(designLabel{1,1},'session')) any(designLabel{1,2}) & ~(strcmp(designLabel{1,2},'group')|strcmp(designLabel{1,2},'session'))];

% Store selectICsByClusterection channel.
STUDY.clust2ch.channelList = selectICsByClusterChan;

% Pre-allocate memory: when there is within-subject condition. 07/23/2018 Makoto. Edited.
if isempty(find(withinSubjectConditionPresent))
    withinSubjectConditionLabel = 'type'; % In case there is no design specified. 12/03/2018 Makoto.
    disp('No within-subject condition detected. EEG.epoch.eventtype is used for 1latency-zero events.')
else
    conditionLabelsCell = STUDY.design(STUDY.currentdesign).variable(find(withinSubjectConditionPresent)).value;
    STUDY.clust2ch.withinSubjectCondition = conditionLabelsCell;
    withinSubjectConditionLabel           = STUDY.design(STUDY.currentdesign).variable(find(withinSubjectConditionPresent)).label;
    withinSubjectConditionNum             = length(conditionLabelsCell);
end
STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition = cell(length(uniqueSubj),5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Separate conditions in each set file to compute ERP for each condition. %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try % In case ERP is not computed (for example, this solution could be used only for backprojection.) 
    STUDY = std_readerp(STUDY, ALLEEG, 'clusters', 2:length(STUDY.cluster)); % 'clusters' is a MUST, otherwise it'll fail. 07/24/2018 Makoto.
end
variable1Labels = STUDY.design(STUDY.currentdesign).variable(1).value; % The number of rows in STUDY.cluster.erpdata.
variable2Labels = STUDY.design(STUDY.currentdesign).variable(2).value; % The number of columns in STUDY.cluster.erpdata.

for uniqueSubjIdx = 1:length(uniqueSubj)
    
    % Update the waitbar.
    waitBarCount = waitBarCount+1;
    waitbar(waitBarCount/size(uniqueSubj,1), waitBarHandle)
    
    % Load subject data.
    [~, EEG] = pop_newset(ALLEEG, EEG, 1, 'retrieve', uniqueSubj(uniqueSubjIdx,1), 'study', 1);
    
    % Separate conditions.
    latencyZeroEventType = cell(length(EEG.epoch),1);
    for epochIdx = 1:length(EEG.epoch)
        if iscell(EEG.epoch(epochIdx).eventlatency)
            currentLatencyList  = cell2mat(EEG.epoch(epochIdx).eventlatency);
            zeroLatencyEventIdx = find(currentLatencyList==0);
            %latencyZeroEventType{epochIdx} = EEG.epoch(epochIdx).eventtype{zeroLatencyEventIdx}; % This works only if the condition names are stored as 'type'. Corrected. 11/16/2018 Makoto.
            latencyZeroEventType{epochIdx} = EEG.epoch(epochIdx).(['event' withinSubjectConditionLabel]){zeroLatencyEventIdx};
        elseif length(EEG.epoch(epochIdx).eventlatency) == 1; % If there is only one event per epoch. 04/20/2019
            latencyZeroEventType{epochIdx} = EEG.epoch(epochIdx).(['event' withinSubjectConditionLabel]);
        else
            currentLatencyList  = EEG.epoch(epochIdx).eventlatency;
            zeroLatencyEventIdx = find(currentLatencyList==0);
            %latencyZeroEventType{epochIdx} = EEG.epoch(epochIdx).eventtype(zeroLatencyEventIdx); % This works only if the condition names are stored as 'type'. Corrected. 11/16/2018 Makoto.
            latencyZeroEventType{epochIdx} = EEG.epoch(epochIdx).(['event' withinSubjectConditionLabel]){zeroLatencyEventIdx};
        end
    end
        % This works only if there is only one event per epoch. Corrected. % 09/13/2018 Makoto.
        %     allEpochEventLatency = cell2mat({EEG.epoch.eventlatency}');
        %     latencyZeroEventIdx  = find(allEpochEventLatency == 0);
        %     latencyZeroEventType = {EEG.event(latencyZeroEventIdx).type}';
    
    % Compute ERP for each condition.
    allEventTypes = cellfun(@(x) num2str(x), latencyZeroEventType, 'uniformoutput', false);
    allConditionIcaactErp = zeros(size(EEG.icaact,1), size(EEG.icaact,2), length(variable1Labels));
    for conditionIdx = 1:length(variable1Labels)

        if iscell(variable1Labels{conditionIdx})
            currentConditionLabelCell = variable1Labels{conditionIdx};
            currentConditionLabel = '';
            for combinedItemIdx = 1:length(currentConditionLabelCell)
                currentConditionLabel = [currentConditionLabel currentConditionLabelCell{combinedItemIdx}];
                if combinedItemIdx < length(currentConditionLabelCell)
                    currentConditionLabel = [currentConditionLabel '+'];
                end
            end
        else
            currentConditionLabel = num2str(variable1Labels{conditionIdx});
        end
        
        % Obtain the trial index for combined conditions by STUDY. 
        if iscell(variable1Labels{conditionIdx})
            currentConditionLabelCell = variable1Labels{conditionIdx};
            currentConditionIdx = [];
            for combinedItemIdx = 1:length(currentConditionLabelCell)
                currentConditionLabel = currentConditionLabelCell{combinedItemIdx};
                currentConditionIdx   = [currentConditionIdx; find(strcmp(allEventTypes, currentConditionLabel))];
            end
        else
            currentConditionIdx = find(strcmp(allEventTypes, currentConditionLabel));
        end
        
        currentConditionIcaact = mean(EEG.icaact(:,:,currentConditionIdx),3);
        allConditionIcaactErp(:,:,conditionIdx) = currentConditionIcaact;
    end
    
    % Obtain IC index to keep.
    subjIdx   = find(alleegIdx_icIdx_clustIdx_groupSession(:,1)==uniqueSubj(uniqueSubjIdx,1));
    icsToKeep = alleegIdx_icIdx_clustIdx_groupSession(subjIdx,2);

    % Enter the subject ID.
    STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition{uniqueSubjIdx,1} = uniqueSubj(uniqueSubjIdx,1);
    STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition{uniqueSubjIdx,2} = num2str(EEG.group);
    STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition{uniqueSubjIdx,3} = num2str(EEG.session);
    STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition{uniqueSubjIdx,4} = icsToKeep;
    STUDY.clust2ch.alleegIdx_group_session_icIdx_meanIcaactByCondition{uniqueSubjIdx,5} = allConditionIcaactErp;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Save the current subject with selected ICs. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(savePath)
        EEG_innerEnv = pop_subcomp(EEG, setdiff([1:size(EEG.icaweights,1)], icsToKeep), 0);
        EEG_innerEnv = eeg_checkset(EEG_innerEnv, 'ica');
        EEG_innerEnv.etc.originalIcIdxBeforeClusterIcSelection = icsToKeep;
        pop_saveset(EEG_innerEnv, 'filename', [EEG.filename(1:end-4) '_selectICsByCluster'], 'filepath', savePath);
    end
end
close(waitBarHandle)
            
% Save the STUDY.design
STUDY.clust2ch.selectedStudyDesign = STUDY.design(STUDY.currentdesign);

% Update the STUDY in the base workspace.
assignin('base', 'STUDY', STUDY)

disp('Data are stored at STUDY.clust2ch.')
