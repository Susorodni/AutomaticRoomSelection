classdef Member
    properties (SetAccess = private)
        firstName string
        lastName string
        academicClass double {mustBeReal, mustBeFinite, mustBeInteger, mustBeBetween(academicClass, 2, 4)}
        officerRank double {mustBeReal, mustBeFinite, mustBeInteger, mustBeBetween(officerRank, 1, 15)}
        cumulativeGPA double {mustBeReal, mustBeFinite, mustBeBetween(cumulativeGPA, 0.0, 4.0)}
        termGPA double {mustBeReal, mustBeFinite, mustBeBetween(termGPA, 0.0, 4.0)}
    end

    methods
        function obj = Member(firstName, lastName, academicClass, officerRank, cumulativeGPA, termGPA)
            if nargin == 0
                obj.firstName = "";
                obj.lastName = "";
                obj.academicClass = 2;
                obj.officerRank = 15;
                obj.cumulativeGPA = 0.0;
                obj.termGPA = 0.0;
            else
                obj.firstName = firstName;
                obj.lastName = lastName;
                obj.academicClass = academicClass;
                obj.officerRank = officerRank;
                obj.cumulativeGPA = cumulativeGPA;
                obj.termGPA = termGPA;
            end 
        end
    end
end


