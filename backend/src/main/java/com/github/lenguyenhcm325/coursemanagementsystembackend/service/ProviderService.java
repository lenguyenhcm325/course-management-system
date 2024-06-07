package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Provider;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.ProviderRepository;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProviderService {

  private final ProviderRepository providerRepository;
  private final EntityManager entityManager;

  @Autowired
  public ProviderService(ProviderRepository providerRepository, EntityManager entityManager) {
    this.providerRepository = providerRepository;
    this.entityManager = entityManager;
  }

  public Provider saveProvider(Provider provider) {
    return providerRepository.save(provider);
  }

  public Provider getProviderById(int id) {
    return providerRepository.findById(id).orElse(null);
  }

  public List<Provider> getAllProviders() {
    return providerRepository.findAll();
  }

  public void deleteProviderById(int id) {
    providerRepository.deleteById(id);
  }

  public Provider updateProviderById(int id, Provider provider) {
    return providerRepository
        .findById(id)
        .map(
            foundProvider -> {
              foundProvider.setName(provider.getName());
              entityManager.flush();
              entityManager.refresh(foundProvider);
              return foundProvider;
            })
        .orElse(null);
  }
}
