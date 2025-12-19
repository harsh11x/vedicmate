// Wallet Service for managing user wallets and transactions
class WalletService {
  constructor(state) {
    this.state = state;
  }

  getBalance(userId) {
    const wallet = this.state.wallets.find(w => w.clientId === userId);
    if (!wallet) {
      // Create new wallet if doesn't exist
      const newWallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      this.state.wallets.push(newWallet);
      return 0.0;
    }
    return wallet.balance || 0.0;
  }

  addMoney(userId, amount, type = 'recharge', description = '') {
    if (amount <= 0) {
      throw new Error('Amount must be positive');
    }

    let wallet = this.state.wallets.find(w => w.clientId === userId);
    if (!wallet) {
      wallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      this.state.wallets.push(wallet);
    }

    wallet.balance = (wallet.balance || 0) + amount;
    wallet.lastTransaction = Date.now();

    // Create transaction record
    const transaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: Date.now(),
      clientId: userId,
      type: type,
      amount: amount,
      description: description || `Wallet recharge of ₹${amount}`,
      status: 'completed',
      balanceAfter: wallet.balance
    };

    this.state.transactions.push(transaction);
    if (!wallet.transactions) wallet.transactions = [];
    wallet.transactions.push(transaction.id);

    return {
      success: true,
      newBalance: wallet.balance,
      transaction: transaction
    };
  }

  deductMoney(userId, amount, type = 'service', description = '') {
    if (amount <= 0) {
      throw new Error('Amount must be positive');
    }

    const wallet = this.state.wallets.find(w => w.clientId === userId);
    if (!wallet) {
      throw new Error('Wallet not found');
    }

    if (wallet.balance < amount) {
      throw new Error('Insufficient balance');
    }

    wallet.balance = wallet.balance - amount;
    wallet.lastTransaction = Date.now();

    // Create transaction record
    const transaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: Date.now(),
      clientId: userId,
      type: type,
      amount: -amount,
      description: description || `Service charge of ₹${amount}`,
      status: 'completed',
      balanceAfter: wallet.balance
    };

    this.state.transactions.push(transaction);
    if (!wallet.transactions) wallet.transactions = [];
    wallet.transactions.push(transaction.id);

    return {
      success: true,
      newBalance: wallet.balance,
      transaction: transaction
    };
  }

  getTransactions(userId, limit = 50) {
    const userTransactions = this.state.transactions
      .filter(t => t.clientId === userId)
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, limit);

    return userTransactions;
  }

  getWallet(userId) {
    let wallet = this.state.wallets.find(w => w.clientId === userId);
    if (!wallet) {
      wallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      this.state.wallets.push(wallet);
    }
    return wallet;
  }
}

export default WalletService;

