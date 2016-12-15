classdef HarmonicSeriesDisplay < handle
properties
        HarmonicSeries@HarmonicSeries
        PlotFigure
        ControlFigure
    end % properties
    
    properties (Hidden)
        Axes
        Plt
        AmpsControl
        FreqControl
        DescrBox
        PlotButton
        PlotButtonC
    end % properties (hidden)
    
    methods
        %% Constructor
        function app = HarmonicSeriesDisplay()
            % Initiate a HarmonicSeries
            app.HarmonicSeries = HarmonicSeries; %#ok<PROP>
           
            % Build the control panel.
            app.BuildControlPanel
            app.FillControlPanel
        end % function app = HarmonicSeriesDisplay()
        
        function PlotSeries(app, Sender, ~)
            % Read control, and set HarmonicSeries
            try
                app.ReadAndSet
            catch err
                msgbox(err.message)
                app.FillControlPanel
                return
            end

            % Get the figure, or create it.
            if ~isempty(app.PlotFigure) && ishghandle(app.PlotFigure)
                figure(app.PlotFigure);
            else
                app.PlotFigure = figure();
            end
            
            app.Plt = plot(app.HarmonicSeries.TimeArrayPi, app.HarmonicSeries.ResultsSum);
            NumLines = numel(app.Plt);
            Shades = linspace(0.5, 0.1, NumLines-1);
            Colors = {'m', 'r', 'g', 'c', 'b'};
            ci = 0;
            for linei = 1:NumLines
                line = app.Plt(linei);
                ci = ci + 1;
                if ci > NumLines
                    ci = 1;
                end
                if linei ~= NumLines
                    switch Sender
                        case app.PlotButton
                            set(line, 'Color', Shades(linei)*[1,1,1], 'linewidth', 1)
                        otherwise
                            set(line, 'Color', Colors{ci} , 'linewidth', 1)
                    end
                else
                    set(line, 'Color', 'k', 'linewidth', 2)
                end
            end
            xlabel('x')
            ylabel('y')
        end % function PlotSeries(app)
        
        function BuildControlPanel(app)
            
            app.ControlFigure = figure('Visible', 'off', ...
                'Position', [100, 100, 270, 135], ...
                'MenuBar', 'none', ...
                'Name', 'Harmonic Series Control', ...
                'NumberTitle', 'off');
            movegui(app.ControlFigure, 'center')
            
            % Amplitudes
            uicontrol('style', 'text', ...
                'Position', [10, 110, 80, 15], ...
                'String', 'Amplitudes', ...
                'FontWeight', 'bold')
            app.AmpsControl = uicontrol('style', 'edit', ...
                'Position', [100, 110, 160, 15], ...
                'String', '-----');
            
            % Frequencies
            uicontrol('style', 'text', ...
                'Position', [10, 90, 80, 15], ...
                'String', 'Frequencies', ...
                'FontWeight', 'bold')
            app.FreqControl = uicontrol('style', 'edit', ...
                'Position', [100, 90, 160, 15], ...
                'String', '-----');
            
            % Description
            uicontrol('style', 'text', ...
                'Position', [10, 70, 80, 15], ...
                'String', 'Formula', ...
                'FontWeight', 'bold')
            app.DescrBox = uicontrol('style', 'text', ...
                'Position', [100, 35, 160, 50], ...
                'String', '-----');
            
            % Plot
            app.PlotButton = uicontrol('style', 'pushbutton', ...
                'Position', [100, 10, 75, 20], ...
                'String', 'Plot', ...
                'Callback', @app.PlotSeries);
            app.PlotButtonC = uicontrol('style', 'pushbutton', ...
                'Position', [185, 10, 75, 20], ...
                'String', 'Plot Colour', ...
                'Callback', @app.PlotSeries);
            
            set(app.ControlFigure, 'Visible', 'on')
        end % function BuildControlPanel(app)
        
        function FillControlPanel(app)
            
            % Amplitudes
            Str = '';
            for A = app.HarmonicSeries.Amps
                Str = [Str, sprintf('%.*f, ', DecPlaces(A, 3), A)]; %#ok<AGROW>
            end
            Str = Str(1:end-2);
            set(app.AmpsControl, 'String', Str, 'TooltipString', Str)
            
            % Frequencies
            Str = '';
            for A = app.HarmonicSeries.AngFreqs
                Str = [Str, sprintf('%.*f, ', DecPlaces(A, 3), A)]; %#ok<AGROW>
            end
            Str = Str(1:end-2);
            set(app.FreqControl, 'String', Str, 'TooltipString', Str)
            
            % Formula
            Str = app.HarmonicSeries.ResultsString;
            set(app.DescrBox, 'String', Str)
        end % function FillControlPanel(app)
        
        function ReadAndSet(app)
            AmpsStr = get(app.AmpsControl, 'String');
            Amps = strsplit(AmpsStr, ', ');
            Amps = str2double(Amps);
            FreqStr = get(app.FreqControl, 'String');
            Freq = strsplit(FreqStr, ', ');
            Freq = str2double(Freq);
            if numel(Amps) ~= numel(Freq)
                error('HarmonicSeriesDisplay:ReadAndSet:SizeDiff', 'Size of Amplitudes must equal size of frequencies.')
            end
            app.HarmonicSeries.SetFreqsAndAmps(Freq, Amps)
        end % function ReadAndSet(app)
    end
end