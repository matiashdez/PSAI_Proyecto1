clear all
close all
clc

% Seleccionar la imagen que va a ser filtrada
[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
   disp('No se seleccionó ninguna imagen');
   return;
end

% Leer y convertir la imagen a escala de grises
PatternDetection = im2double(imread(fullfile(pathname, filename)));
if size(PatternDetection, 3) == 3  % Convertir a gris si es RGB
    PatternDetection = rgb2gray(PatternDetection);
end

% Configurar la interfaz gráfica para uso más sencillo de los usuarios
fig = figure('Name', 'Image Denoising', 'NumberTitle', 'off', 'Position', get(0, 'Screensize'));

% Definir parámetros iniciales
NoiseDensity = 15; % Densidad del ruido
N = 3; % Tamaño inicial de la vecindad
Ntimes = 25; % Número inicial de iteraciones

% Crear un desplegable para elegir el tipo de ruido
uicontrol('Style', 'text', 'Position', [50 180 200 20], 'String', 'Tipo de Ruido');
NoiseTypeMenu = uicontrol('Style', 'popupmenu', 'String', {'salt & pepper', 'gaussian', 'moteado'}, ...
                          'Position', [50 160 200 20]);

% Crear un eje para mostrar la imagen
ax = axes('Parent', fig, 'Position', [0.1 0.4 0.8 0.6]);
imshow(PatternDetection, 'Parent', ax);
axis image;

% Barra para controlar el tamaño del vecindario N
uicontrol('Style', 'text', 'Position', [50 50 200 20], 'String', 'Tamaño de vecindario (N)');
NSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 10, 'Value', N, 'Position', [50 30 400 20], 'SliderStep', [1/9, 1/9]);
NValueText = uicontrol('Style', 'text', 'Position', [460 30 50 20], 'String', num2str(N));

% Barra para controlar el número de iteraciones
uicontrol('Style', 'text', 'Position', [50 90 200 20], 'String', 'Número de iteraciones (Ntimes)');
NtimesSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 50, 'Value', Ntimes, 'Position', [50 70 400 20], 'SliderStep', [1/49, 1/49]);
NtimesValueText = uicontrol('Style', 'text', 'Position', [460 70 50 20], 'String', num2str(Ntimes));

% Barra para controlar la densidad de ruido
uicontrol('Style', 'text', 'Position', [50 130 200 20], 'String', 'Densidad de ruido (%)');
NoiseDensitySlider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 100, 'Value', NoiseDensity, 'Position', [50 110 400 20]);
NoiseDensityValueText = uicontrol('Style', 'text', 'Position', [460 110 50 20], 'String', num2str(NoiseDensity));

% Configurar los callbacks para que updateImage obtenga los valores de las
% barras
set(NSlider, 'Callback', @(src, event) updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText));
set(NtimesSlider, 'Callback', @(src, event) updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText));
set(NoiseDensitySlider, 'Callback', @(src, event) updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText));
set(NoiseTypeMenu, 'Callback', @(src, event) updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText));

% Función para actualizar la imagen
function updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText)
    % Obtener valores de las barras y el tipo de ruido seleccionado
    N = round(get(NSlider, 'Value'));
    Ntimes = round(get(NtimesSlider, 'Value'));
    NoiseDensity = get(NoiseDensitySlider, 'Value');
    NoiseTypeOptions = get(NoiseTypeMenu, 'String');
    selectedNoiseType = NoiseTypeOptions{get(NoiseTypeMenu, 'Value')};
    
    % Actualizar los valores mostrados en las casillas de texto
    set(NValueText, 'String', num2str(N));
    set(NtimesValueText, 'String', num2str(Ntimes));
    set(NoiseDensityValueText, 'String', num2str(NoiseDensity));
    
    % Aplicar ruido en función del tipo seleccionado
    if strcmp(selectedNoiseType, 'salt & pepper')
        NoisyImage = imnoise(PatternDetection, 'salt & pepper', NoiseDensity / 100);
    elseif strcmp(selectedNoiseType, 'gaussian')
        NoisyImage = imnoise(PatternDetection, 'gaussian', 0, NoiseDensity / 1000);
    elseif strcmp(selectedNoiseType, 'moteado')
        NoisyImage = imnoise(PatternDetection, 'speckle', NoiseDensity / 100);
    end

    % Aplicar filtros
    MeanFilter = conv2(NoisyImage, ones(N) / N^2, 'same'); % Media
    MedianFilterR = NoisyImage; % Mediana
    for i = 1:Ntimes
        MedianFilterR = medfilt2(MedianFilterR, [N N]);
    end

    % Mostrar resultados
    subplot(2, 2, 1), imshow(NoisyImage), title(['Imagen con Ruido (' selectedNoiseType ')']);
    subplot(2, 2, 2), imshow(MeanFilter), title(['Filtro de Media (' num2str(N) 'x' num2str(N) ')']);
    subplot(2, 2, 3), imshow(medfilt2(NoisyImage, [N N])), title(['Filtro de Mediana (' num2str(N) 'x' num2str(N) ')']);
    subplot(2, 2, 4), imshow(MedianFilterR), title(['Filtro de Mediana Repetido (' num2str(Ntimes) ' veces)']);
end

% Llamada inicial para mostrar la imagen
updateImage(NSlider, NtimesSlider, NoiseDensitySlider, NoiseTypeMenu, PatternDetection, NValueText, NtimesValueText, NoiseDensityValueText);