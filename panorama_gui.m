function varargout = panorama_gui(varargin)
% PANORAMA_GUI MATLAB code for panorama_gui.fig
%      PANORAMA_GUI, by itself, creates a new PANORAMA_GUI or raises the existing
%      singleton*.
%
%      H = PANORAMA_GUI returns the handle to a new PANORAMA_GUI or the handle to
%      the existing singleton*.
%
%      PANORAMA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PANORAMA_GUI.M with the given input arguments.
%
%      PANORAMA_GUI('Property','Value',...) creates a new PANORAMA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before panorama_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to panorama_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help panorama_gui

% Last Modified by GUIDE v2.5 12-Mar-2015 18:52:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @panorama_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @panorama_gui_OutputFcn, ...
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


% --- Executes just before panorama_gui is made visible.
function panorama_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to panorama_gui (see VARARGIN)

% Choose default command line output for panorama_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% setup vlfeat
run('lib/vlfeat-0.9.20/toolbox/vl_setup');

% UIWAIT makes panorama_gui wait for user response (see UIRESUME)
% uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = panorama_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
pos = get(handles.single,'Position');
width = pos(3);% get the height
if width > 1
    val = get(hObject,'Value');
    xPos = -(width-1) + (width-1)*(1-val);
    pos(1) = xPos;
    set(handles.single,'Position',pos);
end

% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fNames fPath] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'; ...
    '*.*','All Files' },'Select Images','MultiSelect','on');

set(handles.slider,'Value',0.0); % reset slider

%return if no values
if ~iscell(fNames)
    return
end

% get filenames
size = length(fNames);
files = cell([1 size]);
for i = 1:size
    files(i) = fullfile(fPath, fNames(i));
end
files = fliplr(files)
imgs = loadImages(files);

% reset final img
if isappdata(handles.figure,'full_img')
    rmappdata(handles.figure,'full_img')
end

if isappdata(handles.figure,'finalImgAxes')
    ax = getappdata(handles.figure,'finalImgAxes');
    cla(ax);
    rmappdata(handles.figure,'finalImgAxes');
end

% init axes
hAxes = getappdata(handles.figure,'hAxes');
if ~isempty(hAxes)
    f = find ( ishandle(hAxes) & hAxes);
    delete(hAxes(f));
end
hAxes = zeros(size,1);

axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.single, [1.0 1.0 1.0], 'off', 'off'};
imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};

wid = 0.5 * size;
if wid < 1
    wid = 1;
end
po = 1.0 - wid;
pos = get(handles.single, 'Position');
pos(3) = wid;
pos(1) = 0;
set(handles.single, 'Position', pos);

% image position constants
y = 1 - 0.98; % x position (1 row)
rPitch = 0.98/size;
axHight = 0.9/1;
axWidth = 0.9/size;

% post images into LDR panel
h = waitbar(0, 'Loading images...'); % start progress bar
for i = 1:size
    % create axes
    x = 1 - (i) * rPitch; % x position
    hAxes(i) = axes('Position', [x y axWidth axHight], axesProp, axesVal);
    
    % draw image in axes
    imagesc(imgs(:,:,:,i),'Parent',hAxes(i),imageProp,imageVal);
    axis(hAxes(i),'image');
    axis(hAxes(i),'off');
    
    waitbar(i / size); % progress bar update
end

close(h);
set(handles.stitch,'Enable','on');
setappdata(handles.figure,'hAxes',hAxes);
setappdata(handles.figure,'images',flip(imgs,4));

% --- Executes on button press in stitch.
function stitch_Callback(hObject, eventdata, handles)
% hObject    handle to stitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%reset
if isappdata(handles.figure,'finalImgAxes')
    ax = getappdata(handles.figure,'finalImgAxes');
    cla(ax);
    rmappdata(handles.figure,'finalImgAxes');
end
if isappdata(handles.figure,'full_img')
    rmappdata(handles.figure,'full_img')
end

% extract exposure correction
switch get(get(handles.exp_corr,'SelectedObject'),'Tag')
    case 'exp_on',  matchExp = true;
    case 'exp_off',  matchExp = false;
    otherwise, matchExp = true; % default... should never happen
end

% extract blending type
switch get(get(handles.blend_opt,'SelectedObject'),'Tag')
    case 'blend_none',  blend = 'NoBlend';
    case 'blend_alpha',  blend = 'Alpha';
    case 'blend_pyr',  blend = 'Pyramid';
    otherwise, blend = 'NoBlend'; % default... should never happen
end

% extract type and compute
imgs = getappdata(handles.figure,'images');
h = waitbar(0, 'Building panorama...'); % start progress bar
switch get(get(handles.construct_opt,'SelectedObject'),'Tag')
    case 'cyl'
        % load cylindrical properties
        f = str2double(get(handles.cyl_f,'String'));
        k1 = str2double(get(handles.cyl_k1,'String'));
        k2 = str2double(get(handles.cyl_k2,'String'));
        loop = get(handles.cyl_loop,'Value');
        
        %check
        if isempty(f) || isempty(k1) || isempty(k2)
            warndlg('All parameters for cylindrical options must be set and numbers!');
            return;
        end
        
        %compute
        full_img = createPanoramaCyl(imgs, f, k1, k2, loop, matchExp, blend);
    case 'hom'
        full_img = createPanoramaPla(imgs, matchExp, blend);
    otherwise % cylindrical by default
        % load cylindrical properties
        f = str2double(get(handles.cyl_f,'String'));
        k1 = str2double(get(handles.cyl_k1,'String'));
        k2 = str2double(get(handles.cyl_k2,'String'));
        loop = get(handles.cyl_loop,'Value');
        
        %check
        if isempty(f) || isempty(k1) || isempty(k2)
            warndlg('All parameters for cylindrical options must be set and numbers!');
            return;
        end
        
        %compute
        full_img = createPanoramaCyl(imgs, f, k1, k2, loop, matchExp, blend);
end
close(h);
full_img = uint8(full_img);

%display on gui
imageProp = {'ButtonDownFcn'};
imageVal = {'enlargeImage( guidata(gcf) )'};
x = 1 - 0.98; % x position (1 column)
y = 1 - 0.98; % y position (1 row)
axWidth = 0.96;
axHight = 0.96;
axesProp = {'DataAspectRatio' ,'Parent','PlotBoxAspectRatio','XGrid','YGrid'};
axesVal = {[1.0 1.0 1.0], handles.final, [1.0 1.0 1.0], 'off', 'off'};
finalImgAxes = axes('Position', [x y axWidth axHight], axesProp, axesVal);
imagesc(full_img,'Parent',finalImgAxes,imageProp,imageVal);
axis(finalImgAxes,'image');
axis(finalImgAxes,'off');

setappdata(handles.figure,'full_img',full_img);
setappdata(handles.figure,'finalImgAxes',finalImgAxes);


% --- Executes on button press in cyl_loop.
function cyl_loop_Callback(hObject, eventdata, handles)
% hObject    handle to cyl_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cyl_loop


function cyl_f_Callback(hObject, eventdata, handles)
% hObject    handle to cyl_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyl_f as text
%        str2double(get(hObject,'String')) returns contents of cyl_f as a double


% --- Executes during object creation, after setting all properties.
function cyl_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyl_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cyl_k2_Callback(hObject, eventdata, handles)
% hObject    handle to cyl_k2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyl_k2 as text
%        str2double(get(hObject,'String')) returns contents of cyl_k2 as a double

    
% --- Executes during object creation, after setting all properties.
function cyl_k2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyl_k2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cyl_k1_Callback(hObject, eventdata, handles)
% hObject    handle to cyl_k1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyl_k1 as text
%        str2double(get(hObject,'String')) returns contents of cyl_k1 as a double


% --- Executes during object creation, after setting all properties.
function cyl_k1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyl_k1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
