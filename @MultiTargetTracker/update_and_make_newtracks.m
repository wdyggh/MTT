function o = update_and_make_newtracks(o, time, observations, gate_membership_matrix, data_association_matrix)

new_tracks = {};
num_of_observations = length(observations);
num_of_tracks = length(o.list_of_tracks);

for i = 1:num_of_observations
    current_observation = observations{i};
    % If the last column is 1 for an observation then a new target has to be made
    % If the new target is not within the gate of any existing tracks, then a new track is made with default initial
    % parameters. If the new target is within the gate of some existing tracks, then a new track is made by deriving the
    % track from the nearest track to the observation.
    
    if data_association_matrix(i, end) == 1
        if gate_membership_matrix(i, end) == 1
            initial_state = [current_observation', o.filter_parameters.rest_of_initial_state']';
            t = Track(o.filter_parameters.A,  o.filter_parameters.C, o.filter_parameters.Q, o.filter_parameters.R, initial_state);
            t = t.record_predicted_observation(time);
            t = t.record_associated_observation(time, current_observation);
        else
            cost_vector = Inf * ones(1, num_of_tracks);
            for j = 1:num_tracks
                current_track = o.list_of_tracks{j};
                if gate_membership_matrix(i, j) == 1
                    cost_vector(j) = distance(current_observation, current_track.get_observation());
                end
            end
            [~, track_from_which_split] = min(cost_vector);
            t = o.list_of_tracks{track_from_which_split}.split_copy();
            t = t.update(current_observation);
            t = t.record_predicted_observation(time);
            t = t.record_associated_observation(time, current_observation);
        end

        new_tracks{end + 1} = t;
    else
        for j = 1:num_of_tracks
            if data_association_matrix(i, j) == 1
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
                o.list_of_tracks{j} = o.list_of_tracks{j}.update(current_observation);
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_associated_observation(time, current_observation);
            end 
        end
    end
end

% For the tracks which do not have any associated observations the current time and observation is recorded
for j = 1:num_of_tracks
    if sum(data_association_matrix(:, j)) == 0
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
    end
end

o.list_of_tracks = [o.list_of_tracks, new_tracks];
end