package com.example.expensetracker;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ExpenseAdapter extends RecyclerView.Adapter<ExpenseAdapter.ViewHolder> {
    private final List<Expense> expenseList;

    public ExpenseAdapter(List<Expense> expenseList) {
        this.expenseList = expenseList;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        private final TextView descriptionTextView;
        private final TextView amountTextView;

        public ViewHolder(View view) {
            super(view);
            descriptionTextView = view.findViewById(R.id.expenseDescription);
            amountTextView = view.findViewById(R.id.expenseAmount);
        }

        public void bind(Expense expense) {
            descriptionTextView.setText(expense.getDescription());
            amountTextView.setText("$" + String.format("%.2f", expense.getAmount()));
        }
    }

    @NonNull
    @Override
    public ExpenseAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.expense_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ExpenseAdapter.ViewHolder holder, int position) {
        Expense expense = expenseList.get(position);
        holder.bind(expense);
        Log.d("ExpenseAdapter", "Binding: " + expense.getDescription() + " - " + expense.getAmount());
    }

    @Override
    public int getItemCount() {
        return expenseList.size();
    }

    // Optional: method to add a new expense
    public void addExpense(Expense expense) {
        expenseList.add(expense);
        notifyItemInserted(expenseList.size() - 1);
    }
}

