classdef Member
    %MEMBER Contains necessary information of a member to determine
    % rankings
    %
    % By default, a Member with no defined properties will have a blank
    % name, and lowest academicClass, officerRank, and 0 for cumulativeGPA
    % and termGPA. If defined, the properties will be used to determine a
    % RoomGroup rank.

    properties (SetAccess = private)
        lastName string % Last name of a member. Used for primary identification
        academicClass double {mustBeReal, mustBeFinite, mustBeInteger, mustBeBetween(academicClass, 2, 4)} % The current academic standing, goes from 2 (Sophomore) to 4 (Senior)
        officerRank double {mustBeReal, mustBeFinite, mustBeInteger, mustBeBetween(officerRank, 1, 15)} % Officer rank, goes from 1 to 15, with the numbers correlating to the defined officer ranks in the MEMBERS.csv file
        cumulativeGPA double {mustBeReal, mustBeFinite, mustBeBetween(cumulativeGPA, 0.0, 4.0)} % Cumulative GPA of the Member
        termGPA double {mustBeReal, mustBeFinite, mustBeBetween(termGPA, 0.0, 4.0)} % Most recent term GPA of the Member
    end

    methods
        function obj = Member(lastName, academicClass, officerRank, cumulativeGPA, termGPA)
            %MEMBER Creates a Member object
            if nargin == 0
                % If no arguments are defined, then default Member is made
                obj.lastName = "";
                obj.academicClass = 2;
                obj.officerRank = 15;
                obj.cumulativeGPA = 0.0;
                obj.termGPA = 0.0;
            else
                % Arguments are defined.
                obj.lastName = lastName;
                obj.academicClass = academicClass;
                obj.officerRank = officerRank;
                obj.cumulativeGPA = cumulativeGPA;
                obj.termGPA = termGPA;
            end
        end
    end
end


