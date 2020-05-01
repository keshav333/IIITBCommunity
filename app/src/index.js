import Web3 from "web3";
import IIITBArtifact from "../../build/contracts/IIITB.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = IIITBArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        IIITBArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  setStatus: function(message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },

  setLookup: function(message) {
    const lookup = document.getElementById("lookup");
    lookup.innerHTML = message;
  },

  createCommunity: async function() {
    const { createCommunity } = this.meta.methods;
    const name = document.getElementById("communityName").value;
    const id = document.getElementById("communityId").value;
    await createCommunity(name, id).send({from: this.account});
    App.setStatus("New Community Owner is " + this.account + ".");
  },

  // Implement Task 4 Modify the front end of the DAPP
 /* lookup: async function (){
    const { lookUpTokenIdToCommunityInfo }  = this.meta.methods;
    const id = document.getElementById("lookId").value;
    
    await lookUpTokenIdToCommunityInfo(id).call().then((name) => {

        App.setLookup("Community: Id = " + id + ", Name = " +name);
    });
  }
*/
  lookup: async function (){
    const { lookUptokenIdToCommunityInfo } = this.meta.methods;
    console.log("keshav is good");
    const id = document.getElementById("lookId").value;
    console.log(id);
    let name = await lookUptokenIdToCommunityInfo(id).call();
    console.log(name);
    App.setStatus("Community: Id = " + id + ", Name = " +name);
  }

};

window.App = App;

window.addEventListener("load", async function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    await window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live",);
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"),);
  }

  App.start();
});