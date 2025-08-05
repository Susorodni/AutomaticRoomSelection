function Main()
    %% Standard procedure 
    clc
    clear variables
    close all
    
    %% Import Member Data
    filename_members = 'MEMBERS.csv';
    
    try
        MEMBERS = readtable(filename_members);
    catch err
        errorMessage = sprintf('Error reading file "%s":\n%s', filename_members, err.message);
        errordlg(errorMessage, 'MEMBERS.csv Reading Error');
    end
    
    % Convert 'LastName' column from cell to string
    MEMBERS.LastName = string(MEMBERS.LastName);
    
    %% Import RoomGroup Data
    filename_roomgroups = 'ROOM_GROUPS.csv';
    try
        ROOM_GROUPS = readtable(filename_roomgroups);
    catch err
        errorMessage = sprintf('Error reading file "%s":\n%s', filename_roomgroups, err.message);
        errordlg(errorMessage, 'ROOM_GROUPS.csv Reading Error');
    end
    
    % Convert the 'Member1Last' and 'Member2Last' columns to string
    ROOM_GROUPS.Member1Last = string(ROOM_GROUPS.Member1Last);
    ROOM_GROUPS.Member2Last = string(ROOM_GROUPS.Member2Last);
    
    % Convert the 'Squatting' column to logical column
    ROOM_GROUPS.Squatting = logical(ROOM_GROUPS.Squatting);
    
    %% Create the Members
    numMembers = size(MEMBERS.FirstName, 1);
    defaultMember = Member();
    
    % Pre-allocate the members array with the defaultMember
    members = repmat(defaultMember, 1, numMembers);
    
    % Fill the members array from the imported MEMBERS data
    for index = 1:1:numMembers
        members(index) = Member(MEMBERS.LastName(index), MEMBERS.AcademicClass(index), MEMBERS.OfficeRank(index), MEMBERS.CumulativeGPA(index), MEMBERS.QuarterlyGPA(index));
    end
    
    %% Create the Room Groups
    numRoomGroups = size(ROOM_GROUPS.Member1Last, 1);
    defaultRoomGroup = RoomGroup();
    
    % Pre-allocate the roomGroups array with the defaultRoomGroup
    roomGroups = repmat(defaultRoomGroup, 1, numRoomGroups);
    
    % Fill the roomGroups array from the imported ROOM_GROUPS data
    for index = 1:1:numRoomGroups
        % Make a tempMembers array that holds the member(s) that will be in
        % that row
        tempMembers(1) = Member();
        tempMembers(1) = members([members.lastName] == ROOM_GROUPS.Member1Last(index));
    
        % If there is more than one Member, add it to the tempMembers array
        if strlength(ROOM_GROUPS.Member2Last(index)) > 0
            thing = members([members.lastName] == ROOM_GROUPS.Member2Last(index));
            tempMembers(2) = thing;
        end
    
        % Add the individual room selections to their own array for each
        % RoomGroup
        roomSelections(1) = ROOM_GROUPS.Preference1(index);
        roomSelections(2) = ROOM_GROUPS.Preference2(index);
        roomSelections(3) = ROOM_GROUPS.Preference3(index);
        roomSelections(4) = ROOM_GROUPS.Preference4(index);
        roomSelections(5) = ROOM_GROUPS.Preference5(index);
    
        % Create the row for this RoomGroup on the roomGroups table
        roomGroups(index) = RoomGroup(tempMembers, roomSelections, ROOM_GROUPS.Squatting(index));
        clear tempMembers;
    end
    
    %% Make the rankings
    % Create the rankings table, using the defined properties in roomGroups
    rankings = table(...
        {roomGroups.members}', ...
        [roomGroups.numMembers]', ...
        [roomGroups.lowestAcademicClass]', ...
        [roomGroups.highestOfficerRank]', ...
        [roomGroups.meanCumulativeGPA]', ...
        [roomGroups.meanTermGPA]', ...
        [roomGroups.squatting]', ...
        {roomGroups.roomSelections}', ...
        'VariableNames', { ...
        'members', ...
        'numMembers', ...
        'lowestAcademicClass', ...
        'highestOfficerRank', ...
        'meanCumulativeGPA', ...
        'meanTermGPA', ...
        'squatting', ...
        'roomSelections'});
    
    %% Sort the rankings
    rankings = sortrows(rankings, ...
        { ...
        'numMembers', ...
        'lowestAcademicClass', ...
        'highestOfficerRank', ...
        'meanCumulativeGPA', ...
        'meanTermGPA' ...
        }, { ...
        'descend', ...
        'ascend', ...
        'ascend', ...
        'descend', ...
        'descend' ...
        });
    
    %% Make selections from the rankings
    % Define the available rooms
    AVAILABLE_ROOMS = [101 102 103 104 105 106 107 108 109 110 111 112 113 114 201 202 203 204 205 206 207 208 209];
    
    % Make a blank table for successful and unsucessful selections
    selections = table('Size', ...
        [0, numel({'Member1', 'Member2', 'Room'})], ...
        'VariableNames', ...
        { ...
        'Member1', ...
        'Member2', ...
        'Room' ...
        }, ...
        'VariableTypes', ...
        { ...
        'string', ...
        'string', ...
        'double' ...
        });
    noSelections = table('Size', ...
        [0, numel({'Member1', 'Member2', 'Room'})], ...
        'VariableNames', ...
        { ...
        'Member1', ...
        'Member2', ...
        'Room' ...
        }, ...
        'VariableTypes', ...
        { ...
        'string', ...
        'string', ...
        'double'});
    
    % Loop through four different rounds
    for round = 1:4
        remainingRoomGroups = size(rankings, 1);
        index = 1;
    
        disp("ROUND " + round + newline);
        disp("---------")
        disp("");
    
        while index <= remainingRoomGroups
            % Pulls current roomGroup
            roomMembers = rankings.members{index};
            memberLast1 = roomMembers(1).lastName;
            memberLast2 = "";
            
            if size(roomMembers, 2) > 1
                memberLast2 = roomMembers(2).lastName;
            end
    
            disp("Current room group at Index " + index);
            disp("Member 1: " + memberLast1);
            disp("Member 2: " + memberLast2 + newline);
    
            % Make empty entry, giving the room number '999' until an available
            % room is found. If not, the room number '999' will be used to
            % identify an unsucessful selection.
            entry = table( ...
                {memberLast1}', ...
                {memberLast2}', ...
                999, 'VariableNames', {'Member1', 'Member2', 'Room'});
    
            % Pulls the index from the ROOM_GROUPS table, which will be
            % different than the index used to pull the room group from the
            % rankings table
            roomGroupIndex = find(ROOM_GROUPS.Member1Last == memberLast1, 1);
    
            criteria = false;
    
            % Determines whether or not current room group meets criteria for
            % this round
            switch round
                case 1
                    criteria = rankings.squatting(index);
                    disp("Squatting is: " + criteria);
                case 2
                    criteria = rankings.lowestAcademicClass(index) >= 4;
                    disp("Senior is: " + criteria);
                case 3
                    criteria = rankings.lowestAcademicClass(index) >= 3;
                    disp("Junior is: " + criteria);
                case 4
                    criteria = true;
            end
    
            if criteria
                % If criteria is met, loop through the five preferences until
                % an available room is found
                for i = 1:5
                    % Used to dynamically go through Preference columns
                    colName = sprintf('Preference%d', i);
                    colData = ROOM_GROUPS.(colName);
                    roomSelection = colData(roomGroupIndex);
                    roomAvailable = AVAILABLE_ROOMS == roomSelection;
                    disp("Preference " + i + ", Room " + roomSelection);
    
                    if any(roomAvailable)
                        % If a room is available, change current entry
                        % selection to the preference
                        entry.Room(1) = roomSelection;
    
                        % Append the selection to the selections table
                        selections = [selections; entry];
    
                        % Remove current room group from the rankings
                        rankings(index, :) = [];
                        remainingRoomGroups = remainingRoomGroups - 1;
    
                        % Remove picked room from the available rooms
                        AVAILABLE_ROOMS(find(AVAILABLE_ROOMS == roomSelection, 1)) = [];
                        disp("Room " + roomSelection + " is available and has been picked");
                        break;
                    else
                        disp("Room not available");
                    end
                end
                
                % If no available room is found, remove room group from the
                % rankings and add them to the noSelections table.
                if entry.Room(1) == 999
                    noSelections = [noSelections; entry];
                    rankings(index, :) = [];
                    remainingRoomGroups = remainingRoomGroups - 1;
                end
            else
                % If room group does not meet criteria, they are skipped and
                % the next room group is up.
                disp("Current room group does not meet criteria for this round");
                index = index + 1;
            end
    
            disp(newline);
        end 
    end
    
    %% Display results
    disp("-----------");
    disp("  RESULTS  ");
    disp("-----------");
    
    missingSelections = size(noSelections, 1) > 0;
    
    if missingSelections
        msgbox("Not all Room Groups were able to make successful selections." ...
            + newline ...
            + "There are " ...
            + size(noSelections, 1) ...
            + " remaining Room Group(s).", "Missing Assignments", "warn");
    else
        msgbox("All Room Groups have successfully been assigned a room!", "Rooms Successfully Assigned!", "help");
    end
    
    if size(AVAILABLE_ROOMS, 2) > 0
        msgbox("There are empty rooms which have not been assigned tenants. They are:" + newline + newline + sprintf(' %d', AVAILABLE_ROOMS) + ".", "Unfilled Rooms", "help");
    end
    
    %% Generate table output
    selections = sortrows(selections, 'Room', 'ascend');
    selectionsFigure = uifigure('Position', [100 100 600 400], 'Name', 'Room Assignments');
    uitable(selectionsFigure, 'Data', selections, ...
            'ColumnName', selections.Properties.VariableNames, ...
            'RowName', {}, ... 
            'Units', 'Normalized', ...
            'Position', [0.05 0.05 0.9 0.9]);
    
    if missingSelections
        noSelectionsFigure = uifigure('Position', [100 100 600 400], 'Name', 'Missing Assignments');
        uitable(noSelectionsFigure, 'Data', noSelections, ...
                'ColumnName', selections.Properties.VariableNames, ...
                'RowName', {}, ... 
                'Units', 'Normalized', ...
                'Position', [0.05 0.05 0.9 0.9]);
    end
end