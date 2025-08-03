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

    roomGroups(index) = RoomGroup(tempMembers, roomSelections);
    clear tempMembers;
end

%% Make the rankings
rankings = table( ...
    {roomGroups.members}', ...
    [roomGroups.numMembers]', ...
    [roomGroups.lowestAcademicClass]', ...
    [roomGroups.highestOfficerRank]', ...
    [roomGroups.meanCumulativeGPA]', ...
    [roomGroups.meanTermGPA]', ...
    'VariableNames', {'members', 'numMembers', 'lowestAcademicClass', 'highestOfficerRank', 'meanCumulativeGPA', 'meanTermGPA'});

%% Sort the rankings
rankings = sortrows(rankings, {'numMembers', 'lowestAcademicClass', 'highestOfficerRank', 'meanCumulativeGPA', 'meanTermGPA'}, {'descend', 'ascend', 'ascend', 'descend', 'descend'});

