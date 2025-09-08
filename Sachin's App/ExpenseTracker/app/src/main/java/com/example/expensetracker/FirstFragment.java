package com.example.expensetracker;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import com.example.expensetracker.databinding.FragmentFirstBinding;

import java.util.ArrayList;
import java.util.List;

public class FirstFragment extends Fragment {
    private FragmentFirstBinding binding;
    private EditText editDescription, editAmount;
    private Button btnAddExpense;
    private List<Expense> expenses = new ArrayList<>();
    private ExpenseAdapter adapter;
    private DatabaseReference databaseReference;

    private RecyclerView listExpenses;

   private TextView textTotal;
   private double total = 0.0;


    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {

        binding = FragmentFirstBinding.inflate(inflater, container, false);
        return binding.getRoot();

    }

    @Override
    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        databaseReference = FirebaseDatabase.getInstance().getReference("expenses");

        editDescription = view.findViewById(R.id.editDescription);
        editAmount = view.findViewById(R.id.editAmount);
        btnAddExpense = view.findViewById(R.id.btnAddExpense);
        listExpenses = view.findViewById(R.id.recyclerExpenses);
        textTotal = view.findViewById(R.id.textTotal);

        adapter = new ExpenseAdapter(expenses);
        listExpenses.setLayoutManager(new LinearLayoutManager(getContext()));
        listExpenses.setAdapter(adapter);

        btnAddExpense.setOnClickListener(v -> {
            String desc = editDescription.getText().toString();
            String amountText = editAmount.getText().toString();

            if (!desc.isEmpty() && !amountText.isEmpty()) {
                double amount = Double.parseDouble(amountText);
                Expense expense = new Expense(desc, amount);
                expenses.add(expense);
                total += amount;

                String expenseId = databaseReference.push().getKey();
                if (expenseId != null) {
                    databaseReference.child(expenseId).setValue(expense);
                }

                adapter.notifyItemInserted(expenses.size() - 1);

                textTotal.setText("Total: $" + String.format("%.2f", total));


                editDescription.setText("");
                editAmount.setText("");
            }
        });


    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

}