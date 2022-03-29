pragma solidity ^0.4.12;

// SPDX-License-Identifier: GPL-3.0

import "./Ownable.sol";
import "./SafeMath.sol";

contract President is Ownable {

using SafeMath for uint256;

    // Objet liste de tous les candidats qui existe
    struct Candidat {
        uint id;
        address ethadress;
        string name;
    }
    
    // Objet liste des candidats selectionnés (exemple: 500 signatures) 
    struct CandidatSelectionned {
        uint id;
        string name;
        uint voteCount;
    }
    
    //vottant
    struct Voters {
        uint id;
        bool hasVoted;
        address[] VoteContent;
    }
    
    uint public candidatselectionnedCount;
    uint public candidatCount;
    uint public votersCount;

    bool public isVotingInSession;
    
    
    address[] Candidates = new address[](30);
    address[] VotersAddresses = new address[](30);
    
    mapping(uint => address) Results;
    mapping(address => Candidat) public candidat;
    mapping(address => Voters) public voters;
    mapping(address => CandidatSelectionned) public candidatselectionned;
    
    event votedEvent (address _address, string confirm);

    //Ajouter des utilisateurs qui sont autorisés à voter pour les candidats selectionnés
    function addVoter (address _address) public onlyOwner {
        require(!isVotingInSession, "Les élections ont déjà commencé");
        
        votersCount++;
        voters[_address] = Voters(
                votersCount,
                false,
                new address[](5)
        );
    }
    
    //Ajout des candidats lambda
    function addCandidat (string memory _name, address _address) public onlyOwner {
        
        //Vérifie si le candidat est déjà dans la liste des candidats
        require(candidatselectionned[_address].id == 0, "Déjà dans la liste");
        

        candidatCount++;
        candidat[_address] = Candidat(
            candidatCount,
            _address,
            _name
        );
    }
    
    //ajout des candidats dans la liste des candidats selectionné
    function addCandidatSelectionned (address _address) public onlyOwner {
        
        //Vérification du début des votes
        require(!isVotingInSession, "Election has already started");
        
        require(candidat[_address].id != 0, "N'est pas dans la \"Candidat\" list.");
    
       candidatselectionnedCount++;
        candidatselectionned[_address] = CandidatSelectionned(
            candidatselectionnedCount,
            candidat[_address].name,
            0
        );
        
        Candidates.push(_address);
    }
    
    //Supprimer les utilisateurs qui sont autorisé à voter
    function removeVoter (address _address) public onlyOwner {
        require(!isVotingInSession, "Election has already started");
        votersCount--;
        delete voters[_address];
    }
    
    //supprimer un candidat de la liste standard
    function removerCandidat (address _address) public onlyOwner {
        candidatCount--;
        delete candidat[_address];
    }
    
    //supprimer un candidat de la liste des candidats selectionné (500 signatures)
    function removeCandidatSelectionned (address _address) public onlyOwner {
        require(!isVotingInSession, "Election has already started");
        candidatselectionnedCount--;
        delete candidatselectionned[_address];
    }
    
    //Function pour voter
    function vote (address _firstChoice) public {
        // vérifier si le vote a déjà été pris en compte
        require(voters[msg.sender].id != 0, "Vous n'êtes pas autoriser à voter.");
        //vérifier si l'utilisateur a déjà voté pour cette session/vote
        require(!voters[msg.sender].hasVoted, "Vous avez déjà voté pour cette session.");

        // vérifie si le candidat est valide.
        require(candidatselectionned[_firstChoice].id != 0, "Adresse introuvable.");

        candidatselectionned[_firstChoice].voteCount += 6;
        
        voters[msg.sender].VoteContent.push(_firstChoice);
        
        voters[msg.sender].hasVoted = true;
        // evenement emit du vote
        emit votedEvent (msg.sender, "Votre vote a été pris en compte");
    }
    

}
