# Avalon_game
Avalon: A real time multiplayer game built on Flutter

The Game consists of 4 Steps:

1. Hosting/Joining the game - This is fairly self explanatory, you can host a game using an unique game key which will be autogenerated. 
   You can also choose to join a game using an existing game key
   
2. Selecting Roles - Host customizes the game by specifying what characters are in play. This will vary from game to game, it is very similar 
   to selecting number of Imposters or Crewmates in popular game 'Among Us'
   
3. Selecting Character - Playes are asked to pick a card to which will allot a role as well as information pertaining to that role

4. Round Table - This is the Main Arena of the game. The player with a yellow glow on their avatar starts first

   4.1 Proposing Quest Teams - The Quest Leader depicted by the yellow glow, will need to propose a team to complete the quest, 
       but beware some of the players are traitors who only wish to ensure the quest fails. Players can pick a team by clicking 
       on a circular player card which will then move to the Team Panel, to deselect, they can click the circular player card 
       again which will bring back the player to the table
       
   4.2 Locking a team - Once the Quest Leader is satisfied they can go ahead and lock the team by clicking on the lock icon. 
       This will immediately trigger a vote on all screens. If the Vote Passes we move on to the next phase of the quest. If
       the quest fails the baton is passed to the next player in sequence to become the new Quest Leader
       
   4.3 Quest Decision - If the Vote passes, Quest Decision options are provided to the players who are a part of the Quest Team 
       chosen earlier. The decisions are provided as pass/fail Cards which represents passing or failing the quest. If in a round 
       even one fail card is encountered, the Quest automatically fails and the Evil team gains a point
       
   4.4 Winning - 
 
       Scenario 1: Evil Team wins if they win 3 rounds
       Scenario 2: Evil team wins if 5 consecutive failed votes happen to enact team
       Scenario 3: Evil team wins if Good team wins 3 rounds and the Evil team succefully find out who Merlin is
       Scenario 4: Good Team wins if they win 3 rounds and Evil team incorrctly identifies Merlin
       
BUGS: 

Any bugs encountered in the App can be posted as an issue on this Github Repo, I will be more than happy to fix it and post updates!
