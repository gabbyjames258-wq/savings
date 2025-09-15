# 📨 MessageChain – On-Chain Messages

MessageChain is a **simple and unique smart contract** that lets users post short text messages permanently on-chain.  
It acts as a **public bulletin board** where every address can have its own message visible forever.  

---

## ✨ Features
- 📨 **Post messages** tied to your wallet address  
- 📜 **Immutable record** of thoughts and notes  
- 🔍 **Anyone can read** your on-chain message  

---

## 🚀 Example Usage

### Post a Message
```clarity
(contract-call? .messagechain post "Hello Stacks World!")
