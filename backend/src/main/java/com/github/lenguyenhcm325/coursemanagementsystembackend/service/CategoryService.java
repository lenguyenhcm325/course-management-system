package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Category;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CategoryService {

  private final CategoryRepository categoryRepository;

  @Autowired
  public CategoryService(CategoryRepository categoryRepository) {
    this.categoryRepository = categoryRepository;
  }

  public Category saveCategory(Category category) {
    return categoryRepository.save(category);
  }

  public Category getCategoryById(int id) {
    return categoryRepository.findById(id).orElse(null);
  }
}
