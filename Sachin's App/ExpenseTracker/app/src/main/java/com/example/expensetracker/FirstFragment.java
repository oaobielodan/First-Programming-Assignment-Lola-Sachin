package com.example.expensetracker;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import com.example.expensetracker.databinding.FragmentFirstBinding;

import java.util.ArrayList;

public class FirstFragment extends Fragment {

    private FragmentFirstBinding binding;
    private EditText editDescription, editAmount;
    private Button btnAddExpense;
    private ListView listExpenses;
    private ArrayList<String> expenses;
    private ArrayAdapter<String> adapter;

    private DatabaseReference databaseReference;



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

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        databaseReference = FirebaseDatabase.getInstance().getReference("expenses");


        editDescription = view.findViewById(R.id.editDescription);
        editAmount = view.findViewById(R.id.editAmount);
        btnAddExpense = view.findViewById(R.id.btnAddExpense);
        listExpenses = view.findViewById(R.id.listExpenses);
        textTotal = view.findViewById(R.id.textTotal);

        expenses = new ArrayList<>();
        adapter = new ArrayAdapter<>(requireContext(), android.R.layout.simple_list_item_1, expenses);
        listExpenses.setAdapter(adapter);

        btnAddExpense.setOnClickListener(v -> {
            String desc = editDescription.getText().toString();
            String amountText = editAmount.getText().toString();

            if (!desc.isEmpty() && !amountText.isEmpty()) {
                double amount = Double.parseDouble(amountText);
                expenses.add(desc + " - $" + amount);
                total += amount;

                String expenseId = databaseReference.push().getKey();
                if (expenseId != null) {
                    Expense expense = new Expense(desc, amountText);
                    databaseReference.child(expenseId).setValue(expense);
                }


                adapter.notifyDataSetChanged();

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