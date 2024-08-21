function varargout = walk_class(varargin)
% WALK_CLASS MATLAB code for walk_class.fig
%      WALK_CLASS, by itself, creates a new WALK_CLASS or raises the existing
%      singleton*.
%
%      H = WALK_CLASS returns the handle to a new WALK_CLASS or the handle to
%      the existing singleton*.
%
%      WALK_CLASS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WALK_CLASS.M with the given input arguments.
%
%      WALK_CLASS('Property','Value',...) creates a new WALK_CLASS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before walk_class_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to walk_class_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help walk_class

% Last Modified by GUIDE v2.5 17-Aug-2023 14:07:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @walk_class_OpeningFcn, ...
                   'gui_OutputFcn',  @walk_class_OutputFcn, ...
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






% --- Executes just before walk_class is made visible.
function walk_class_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to walk_class (see VARARGIN)

% Choose default command line output for walk_class
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes walk_class wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = walk_class_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%load test model
global x_sky_net
[file,path] = uigetfile();
if file == 0
    return;
end
fullpath = sprintf('%s%s',path,file);
x_sky_net = load(fullpath);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%gui_edit = get(handles.edit_string, 'String');
k=0;
%a = arduino('COM5','Uno');

while (k<5)
k = k+1;
system('script.py')
file_name = 'test';
mkdir(file_name);

data = load('result.txt');

I = data(:,1);
Q = data(:,2);

% I_data 저장
data_copy_path_i = sprintf('./%s/',file_name);
data_copy_name_i = sprintf('result_I_data');
data_copy_full_path_i = sprintf('%s%s.txt',data_copy_path_i,data_copy_name_i);

data_copy_txt = fopen(data_copy_full_path_i,'w');
fprintf(data_copy_txt,'%.5f\n',I);
fclose(data_copy_txt);

% Q_data 저장
data_copy_path_Q = sprintf('./%s/',file_name);
data_copy_name_Q = sprintf('result_Q_data');
data_copy_full_path_Q = sprintf('%s%s.txt',data_copy_path_Q,data_copy_name_Q);

data_copy_Q_txt = fopen(data_copy_full_path_Q,'w');
fprintf(data_copy_Q_txt,'%.5f\n',Q);
fclose(data_copy_Q_txt);

% data load후 스펙트로그램 그리기, 저장된 데이터는 가져오지 않는다.
I = data(:,1);
Q = data(:,2);

I(I<0) = 0;
Q(Q<0) = 0;

Z = I + j*Q;
% DC 제거
Z = Z - mean(Z);



PRF = 4000;
obsTime = length(data) / PRF;
rcs_time = linspace(0,obsTime,length(data));

% 윈도우 크기
win_len =  256;

% log spectrogram 이미지 저장
[T F S] = radar_stft(Z, win_len, PRF);
log_spectrogram = figure;
imagesc(T,F, 10*log10(abs(S)))
caxis([-20 -16])
%colorbar
%colormap(jet)
% pcolor(T,F,10*log10(abs(S)))
colormap(flipud(gray(128)));
ylim([-1000 1000])
%caxis([-20 5])
%title('animal');
%xlabel('Time [sec]','Fontsize',15);
%ylabel('Doppler frequency [Hz]','Fontsize',15);
set(gca,'YDir', 'normal');
set(gca,'FontSize',15);
axis off;
set(gca,'xtick',[],'ytick',[]) %눈금 지우기
set(gca, 'LooseInset', get(gca, 'TightInset')); % 테두리 제거
set(gca,'Box','off');
cd(file_name)
saveas(log_spectrogram,'Log_spectrogram.png')
cd('..');
resize_img = imread('C:\Users\NNNNQ\Desktop\walk_classi\test\Log_spectrogram.png');
resize_img2 = imresize(resize_img,[263,350]);
cd(file_name)
imwrite(resize_img2,'Log_spectrogram.png');
cd('..');

% log spectrogram 이미지 GUI에 띄우기
axes(handles.axes1)
imagesc(T,F,10 * log10(abs(S)))
% caxis([-5 -2])
caxis([-20 -16])
colorbar
%colormap(jet)
% pcolor(T,F,10*log10(abs(S)))
colormap(flipud(gray(128)));
ylim([-1000 1000])
title('spectrogram');
%caxis([-20 5])
ylim([-1000 1000])
xlabel('Time [sec]','Fontsize',14);
ylabel('Doppler frequency [Hz]','Fontsize',14);
set(gca,'YDir', 'normal');
set(gca,'FontSize',15);
close(log_spectrogram)

% global 변수
global g_T;
global g_S;
global g_F;
global x_sky_net;
net = x_sky_net.net;

g_T = T;
g_S = S;
g_F = F;
threshold = 0.1;

Zm = mean(abs(Z));
if (Zm < threshold)
    other = 'otherwise';
    
    set(handles.edit3, 'String', char(other));
    %{
    writeDigitalPin(a, 'D8', 0);
    writeDigitalPin(a, 'D9', 0);
    writeDigitalPin(a, 'D7', 0);
    writeDigitalPin(a, 'D6', 0);
    %}
    continue;
else

    new_img = imread('C:\Users\NNNNQ\Desktop\walk_classi\test\Log_spectrogram.png');
    label = classify(net,new_img)
    set(handles.edit3, 'String', char(label));
    %{
    writeDigitalPin(a, 'D8', 0);
    writeDigitalPin(a, 'D9', 0);
    writeDigitalPin(a, 'D7', 0);
    writeDigitalPin(a, 'D6', 0);

    if label == 'human'
        writeDigitalPin(a, 'D8', 1); %점멸등
        writeDigitalPin(a, 'D9', 1); %부저 
    else
        writeDigitalPin(a, 'D7', 1); %플래시
        writeDigitalPin(a, 'D6', 1); %사이렌
    end
%}
end

end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end
