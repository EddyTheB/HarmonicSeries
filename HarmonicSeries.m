classdef HarmonicSeries < handle
    properties (SetAccess = private)
        AngFreqs = [1, 3, 5, 7]
        Amps = [4, 4/3, 4/5, 4/7]
    end % properties (SetAccess = private)
    
    properties    
        OutputPerPeriod = 20
        NumPeriods = 3
    end % properties
    
    properties (Dependent)
        TimeArray
        Results
        ResultsSum
        ResultsString
    end % properties (Dependent)
    
    properties (Dependent, Hidden)
        LowestFreq
        HighestFreq
        AmpsOrderedI
        TimeArrayPi
    end % properties (Dependent, Hidden)
    
    methods
        %% Constructor
        function obj = HarmonicSeries(varargin)
            % HarmonicSeries
            % USAGE
            % H = HarmonicSeries()
            % H = HarmonicSeries(Freqs)
            % H = HarmonicSeries(Freqs, Amps)
            if nargin > 0
                if nargin == 1
                    Freqs = varargin{1};
                    Amps_ = ones(size(Freqs));
                elseif nargin == 2
                    Freqs = varargin{1};
                    Amps_ = varargin{2};
                elseif nargin > 2
                    error('HarmonicSeries:Constructor:TooManyInputs', ...
                        'Too many inputs')
                end
                obj.SetFreqsAndAmps(Freqs, Amps_);
            end
        end % function obj = HarmonicSeries(varargin)
        
        %% Getters and Setters
        function set.OutputPerPeriod(obj, val)
            if val < 5
                error('HarmonicSeries:SetOutputPerPeriod:TooCourse', ...
                    'OutputPerPeriod must be greater or equal than 5.')
            elseif val > 360
                error('HarmonicSeries:SetOutputPerPeriod:TooMany', ...
                    'OutputPerPeriod must be less than or equal to 360.')
            end
            obj.OutputPerPeriod = val;
        end % function set.OutputPerPeriod(obj, val)
            
        function set.NumPeriods(obj, val)
            if val <= 0
                error('HarmonicSeries:NumPeriods:Negative', ...
                    'NumPeriods must be positive.')
            end
            obj.NumPeriods = val;
        end % function set.NumPeriods(obj, val)
        
        function val = get.LowestFreq(obj)
            val = min(obj.AngFreqs);
        end % function val = get.LowestFreq(obj)
        
        function val = get.HighestFreq(obj)
            val = max(obj.AngFreqs);
        end % function val = get.HighestFreq(obj)
        
        function val = get.TimeArray(obj)
            D = 2*pi/(obj.HighestFreq*obj.OutputPerPeriod);
            E = obj.NumPeriods*2*pi/obj.LowestFreq;
            val = 0:D:E;
        end % function val = get.TimeArray(obj)
        
        function val = get.TimeArrayPi(obj)
            val = obj.TimeArray/pi;
        end % function val = get.TimeArrayPi(obj)
        
        function val = get.Results(obj)
            Ts = obj.AngFreqs'*obj.TimeArray;
            Vs = sin(Ts);
            for Ai = 1:numel(obj.Amps)
                Vs(Ai, :) = obj.Amps(Ai)*Vs(Ai, :);
            end
            val = Vs;
        end % function val = get.Results(obj)
        
        function val = get.ResultsSum(obj)
            Results_ = obj.Results;
            ResultsSum_ = zeros(size(Results_));
            AmpsOrderedI_ = obj.AmpsOrderedI;
            for AIi = 1:numel(obj.Amps)
                AI = AmpsOrderedI_(AIi);
                if AIi == 1
                    ResultsSum_(AIi, :) = Results_(AI, :);
                else
                    ResultsSum_(AIi, :) = Results_(AI, :) + ...
                                          ResultsSum_(AIi-1, :);
                end
            end
            val = ResultsSum_;
        end % function val = get.ResultsSum(obj)
        
        function val = get.AmpsOrderedI(obj)
            [~, val] = sort(obj.Amps, 'descend');
        end % function val = get.AmpsOrderedI(obj)
        
        function val = get.ResultsString(obj)
            AmpsOrderedI_ = obj.AmpsOrderedI;
            Str = 'y = ';
            for AIi = 1:numel(obj.Amps)
                AI = AmpsOrderedI_(AIi);
                Str = [Str, sprintf('%.*fsin(%.*fx) + ', ...
                       DecPlaces(obj.Amps(AI)), obj.Amps(AI), ...
                       DecPlaces(obj.AngFreqs(AI)), obj.AngFreqs(AI))]; %#ok<AGROW>
            end
            val = Str(1:end-3);
        end % function val = get.ResultsString(obj)
        
        %% Other methods
        function SetFreqsAndAmps(obj, Freqs, Amps)
            if ~isvector(Freqs)
                error('HarmonicSeries:SetFreqsAndAmps:NotVector', ...
                    'Frequencies must be expressed as a vector of values.')
            end
            if ~isequal(size(Freqs), size(Amps))
                error('HarmonicSeries:SetFreqsAndAmps:NotSameSize', ...
                    'Frequencies and Amplitudes must be expressed as the same size vectors.')
            end
            obj.AngFreqs = Freqs;
            obj.Amps = Amps;
        end % function SetFreqsAndAmps(obj, Freqs, Amps)
    end % methods
end % classdef HarmonicSeries < handle