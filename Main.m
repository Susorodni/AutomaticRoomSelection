%% The usual
clc
clear variables

%% Take care of settings
% Import the officer titles
% filename_officertitles = 'OFFICER_TITLES.csv';
% OFFICER_TITLES = readtable(filename_officertitles);
% OFFICER_TITLES.Title = string(OFFICER_TITLES.Title);

% import the different members
filename_members = 'MEMBERS.csv';
MEMBERS = readtable(filename_members);
MEMBERS.FirstName = string(MEMBERS.FirstName);
MEMBERS.LastName = string(MEMBERS.LastName);
MEMBERS.Office = string(MEMBERS.Office);

% import the room selections
filename_roomgroups = 'ROOM_GROUPS.csv';
ROOM_GROUPS = readtable(filename_roomgroups);
ROOM_GROUPS.Member1Last = string(ROOM_GROUPS.Member1Last);
ROOM_GROUPS.Member2Last = string(ROOM_GROUPS.Member2Last);
ROOM_GROUPS.Squatting = logical(ROOM_GROUPS.Squatting);

%% Create the Members
numMembers = size(MEMBERS.FirstName, 1);
defaultMember = Member();
% pre-allocate members array
members = repmat(defaultMember, 1, numMembers);

% allocate the members array
for index = 1:1:numMembers
    members(index) = Member(MEMBERS.FirstName(index), MEMBERS.LastName(index), MEMBERS.AcademicClass(index), MEMBERS.OfficeRank(index), MEMBERS.CumulativeGPA(index), MEMBERS.QuarterlyGPA(index));
end

%% Create the Room Groups
numRoomGroups = size(ROOM_GROUPS.Member1Last, 1);
defaultRoomGroup = RoomGroup();
% pre-allocate room groups array
roomGroups = repmat(defaultRoomGroup, 1, numRoomGroups);

% allocate the room groups array
for index = 1:1:numRoomGroups
    tempMembers(1) = Member();
    tempMembers(1) = members([members.lastName] == ROOM_GROUPS.Member1Last(index));

    if strlength(ROOM_GROUPS.Member2Last(index)) > 0
        thing = members([members.lastName] == ROOM_GROUPS.Member2Last(index));
        tempMembers(2) = thing;
    end

    roomSelections(1) = ROOM_GROUPS.Preference1(index);
    roomSelections(2) = ROOM_GROUPS.Preference2(index);
    roomSelections(3) = ROOM_GROUPS.Preference3(index);
    roomSelections(4) = ROOM_GROUPS.Preference4(index);
    roomSelections(5) = ROOM_GROUPS.Preference5(index);

    roomGroups(index) = RoomGroup(tempMembers, roomSelections, ROOM_GROUPS.Squatting(index));
    clear tempMembers;
end

%% Make the rankings
rankings = table(...
    {roomGroups.members}', ...
    [roomGroups.numMembers]', ...
    [roomGroups.lowestAcademicClass]', ...
    [roomGroups.highestOfficerRank]', ...
    [roomGroups.meanCumulativeGPA]', ...
    [roomGroups.meanTermGPA]', ...
    [roomGroups.squatting]', ...
    {roomGroups.roomSelections}', ...
    'VariableNames', {'members', 'numMembers', 'lowestAcademicClass', 'highestOfficerRank', 'meanCumulativeGPA', 'meanTermGPA', 'squatting', 'roomSelections'});

%% Sort the rankings
rankings = sortrows(rankings, {'numMembers', 'lowestAcademicClass', 'highestOfficerRank', 'meanCumulativeGPA', 'meanTermGPA'}, {'descend', 'ascend', 'ascend', 'descend', 'descend'});

%% Start Making the selections
AVAILABLE_ROOMS = 1:23; % to update with actual room numbers
selections = table('Size', [0, numel({'Member1', 'Member2', 'Room'})], 'VariableNames', {'Member1', 'Member2', 'Room'}, 'VariableTypes',{'string', 'string', 'double'});
noSelections = table('Size', [0, numel({'Member1', 'Member2', 'Room'})], 'VariableNames', {'Member1', 'Member2', 'Room'}, 'VariableTypes',{'string', 'string', 'double'});

for round = 1:4
    remainingRoomGroups = size(rankings, 1);
    index = 1;

    disp("ROUND " + round + newline);
    disp("---------")
    disp("");

    while index <= remainingRoomGroups
        roomMembers = rankings.members{index};
        memberLast1 = roomMembers(1).lastName;
        memberLast2 = "";
        
        if size(roomMembers, 2) > 1
            memberLast2 = roomMembers(2).lastName;
        end

        disp("Current room group at Index " + index);
        disp("Member 1: " + memberLast1);
        disp("Member 2: " + memberLast2 + newline);


        entry = table( ...
            {memberLast1}', ...
            {memberLast2}', ...
            999, 'VariableNames', {'Member1', 'Member2', 'Room'});

        roomGroupIndex = find(ROOM_GROUPS.Member1Last == memberLast1, 1);

        criteria = false;

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
            for i = 1:5
                colName = sprintf('Preference%d', i);
                colData = ROOM_GROUPS.(colName);
                rgIndex = find(ROOM_GROUPS.Member1Last == memberLast1, 1);
                roomSelection = colData(rgIndex);
                roomAvailable = AVAILABLE_ROOMS == roomSelection;
                disp("Preference " + i + ", Room " + roomSelection);

                if any(roomAvailable)
                    entry.Room(1) = roomSelection;
                    selections = [selections; entry];
                    rankings(index, :) = [];
                    remainingRoomGroups = remainingRoomGroups - 1;
                    AVAILABLE_ROOMS(find(AVAILABLE_ROOMS == roomSelection, 1)) = [];
                    disp("Room " + roomSelection + " is available and has been picked");
                    break;
                else
                    disp("Room not available");
                end
            end

            if entry.Room(1) == 999
                noSelections = [noSelections; entry];
                rankings(index, :) = [];
                remainingRoomGroups = remainingRoomGroups - 1;
            end
        else
            disp("Current room group does not meet criteria for this round");
            index = index + 1;
        end

        disp(newline);
    end 
end

