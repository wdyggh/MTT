classdef Track
    % Implementation of a Track 
    %   A track is a sequence of observations and/or filtered states which
    %   corresponds to an object
    
    properties
        kalman_filter;
        sequence_times_observations; % the time instants at which observations are associated
        sequence_observations; % the set of observations associated to this track
        sequence_times; % all the time instants during which this track is active
        sequence_predicted_observations; % the observations predicted by the internal state
    end
    
    methods
        function o = Track(A, C, Q, R, initial_state)
            o.kalman_filter = KalmanFilter(A, C, Q, R, initial_state);
            o.sequence_times_observations = [];
            o.sequence_observations = {};
            o.sequence_times = [];
            o.sequence_predicted_observations = {};
        end
        
        function o = predict(o)
            o.kalman_filter = o.kalman_filter.predict();
        end
        
        % Records the observation generated by the underlying state of this
        % track (should be called at every point where the track is active)
        function o = record_predicted_observation(o, time)
            o.sequence_times = [o.sequence_times, time];
            o.sequence_predicted_observations{end + 1} = o.get_observation();
        end
        
        % Records an actual observation which has been associated to this
        % track
        function o = record_associated_observation(o, time, observation)
            o.sequence_times_observations = [o.sequence_times_observations, time];
            o.sequence_observations{end + 1} = observation;
        end
        
        function o = update(o, observation)
            o.kalman_filter = o.kalman_filter.update(observation);
        end
        
        function o = split_track(o)
            o.sequence_times_observations = [];
            o.sequence_observations = {};
            o.sequence_times = [];
            o.sequence_predicted_observations = {};
        end
        
        function predicted_observation = get_observation(o)
            predicted_observation = o.kalman_filter.get_observation();
        end
    end
end

