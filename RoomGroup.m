classdef RoomGroup

    properties (SetAccess = private)
        members Member
        numMembers (1,1) double {mustBeMember(numMembers, [1 2])} = 1
        lowestAcademicClass double {mustBeReal, mustBeFinite, mustBeInteger, mustBeBetween(lowestAcademicClass, 2, 4)}
        highestOfficerRank (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(highestOfficerRank, 1), mustBeLessThanOrEqual(highestOfficerRank, 15)} = 15
        meanCumulativeGPA double {mustBeReal, mustBeFinite, mustBeBetween(meanCumulativeGPA, 0.0, 4.0)}
        meanTermGPA double {mustBeReal, mustBeFinite, mustBeBetween(meanTermGPA, 0.0, 4.0)}
        roomSelections double {mustBeReal, mustBeFinite, mustBeInteger}
    end

    methods (Access = public)
        function obj = RoomGroup(members, roomSelections)
            if nargin == 0
                obj.members = Member();
                obj.roomSelections = 101;
                obj.numMembers = 1;
                obj.lowestAcademicClass = 2;
                obj.highestOfficerRank = 15;
                obj.meanCumulativeGPA = 0.00;
                obj.meanTermGPA = 0.00;
            else
                obj.members = members;
                obj.roomSelections = roomSelections;
                obj.numMembers = size(obj.members, 2);
                obj.lowestAcademicClass = getLowestAcademicClass(obj);
                obj.highestOfficerRank = getHighestOfficerRank(obj);
                obj.meanCumulativeGPA = getMeanCumulativeGPA(obj);
                obj.meanTermGPA = getMeanTermGPA(obj);
            end
        end
    end

    methods (Access = private)
        function lowestAcademicClass = getLowestAcademicClass(obj)
            lowestAcademicClass = min([obj.members.academicClass]);
        end

        function highestOfficerRank = getHighestOfficerRank(obj)
            if obj.numMembers > 1
                rank1 = obj.members(1).officerRank;
                rank2 = obj.members(2).officerRank;

                if rank1 > rank2
                    highestOfficerRank = rank1;
                else
                    highestOfficerRank = rank2;
                end
            else
                highestOfficerRank = obj.members(1).officerRank;
            end
        end

        function meanCumulativeGPA = getMeanCumulativeGPA(obj)
            meanCumulativeGPA = mean([obj.members.cumulativeGPA]);
        end

        function meanTermGPA = getMeanTermGPA(obj)
            meanTermGPA = mean([obj.members.termGPA]);
        end
    end
end