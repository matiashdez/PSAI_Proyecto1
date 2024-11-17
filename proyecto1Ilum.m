clear all;
close all;
clc;

% Selección de archivo
[filename, pathname] = uigetfile({'*.jpg;*.png;*.tif', 'Imágenes (*.jpg, *.png, *.tif)'}, 'Selecciona una imagen');
if isequal(filename, 0)
   disp('No se seleccionó ninguna imagen');
   return;
end

% Leer la imagen y convertir a double
Caracterization = im2double(imread(fullfile(pathname, filename)));

% Convertir a escala de grises si es una imagen RGB
if size(Caracterization, 3) == 3
    Caracterization = rgb2gray(Caracterization);
end

% Calcular el brillo medio de la imagen original
meanBrightness = mean(Caracterization(:));

% Crear una figura para mostrar resultados
hFig = figure('Position', [100, 100, 800, 600]);

% Barra para controlar el brillo de la imagen
uicontrol('Style', 'text', 'Position', [50 90 200 20], 'String', 'Brillo');
BrightnessSlider = uicontrol('Style', 'slider', 'Min', -0.5, 'Max', 0.5, 'Value', meanBrightness - 0.5, 'Position', [50 70 400 20], 'SliderStep', [1/100, 1/100]);
BrightnessValueText = uicontrol('Style', 'text', 'Position', [460 70 50 20], 'String', num2str(meanBrightness - 0.5));

% Mostrar imagen y gráficos
subplot(3, 3, 1);
hImgOriginal = imshow(Caracterization); 
title('Imagen Original');

% Histograma de la imagen original
subplot(3, 3, 2);
hHistOriginal = imhist(Caracterization);
bar(hHistOriginal, 'FaceColor', 'b'); % Mostrar el histograma como barras
title('Histograma Original');
xlabel('Intensidad de píxeles');
ylabel('Frecuencia');

% CDF de la imagen original
subplot(3, 3, 3);
hCdfOriginal = cumsum(hHistOriginal) / numel(Caracterization);
plot(hCdfOriginal, 'b', 'LineWidth', 2);
title('CDF de la Imagen Original');
xlabel('Intensidad de píxeles');
ylabel('CDF');

% Función para actualizar la imagen cuando el slider cambia
function updateImage(src, event, BrightnessValueText, Caracterization, meanBrightness)
    % Obtener el valor del slider para ajustar el brillo
    brightnessValue = src.Value;
    set(BrightnessValueText, 'String', num2str(brightnessValue + 0.5));  % Ajuste para mostrar el valor correcto
    
    % Ajustar el brillo de la imagen: El valor del brillo se ajusta
    % entre -0.5 y +0.5 respecto al valor medio
    ImgBrillo = Caracterization + (brightnessValue);  % Aumento o disminución del brillo
    ImgBrillo = max(0, min(1, ImgBrillo));  % Limitar los valores de la imagen en el rango [0, 1]
    
    % Mostrar imagen modificada
    subplot(3, 3, 4);
    imshow(ImgBrillo);
    title('Imagen con Brillo Ajustado');
    
    % Histograma de la imagen con brillo ajustado
    subplot(3, 3, 5);
    hHistBrillo = imhist(ImgBrillo);
    bar(hHistBrillo, 'FaceColor', 'b');
    title('Histograma con Brillo Ajustado');
    xlabel('Intensidad de píxeles');
    ylabel('Frecuencia');
    
    % CDF de la imagen con brillo ajustado
    subplot(3, 3, 6);
    plot(cumsum(hHistBrillo) / numel(ImgBrillo), 'b', 'LineWidth', 2);
    title('CDF de la Imagen con Brillo Ajustado');
    xlabel('Intensidad de píxeles');
    ylabel('CDF');
end

% Establecer la función de callback para el slider
set(BrightnessSlider, 'Callback', @(src, event) updateImage(src, event, BrightnessValueText, Caracterization, meanBrightness));

% Ejecutar la función una vez para mostrar la imagen inicial
updateImage(BrightnessSlider, [], BrightnessValueText, Caracterization, meanBrightness);
