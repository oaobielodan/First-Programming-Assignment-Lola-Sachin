package com.example.expensetracker;

public class Expense {
    public String description;
    public String amount;
    public Expense() {}
    public Expense(String description, String amount) {
        this.description = description;
        this.amount = amount;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }

}
