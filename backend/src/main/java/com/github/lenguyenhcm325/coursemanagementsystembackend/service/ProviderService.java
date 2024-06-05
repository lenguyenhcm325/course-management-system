package com.github.lenguyenhcm325.coursemanagementsystembackend.service;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Provider;
import com.github.lenguyenhcm325.coursemanagementsystembackend.repository.ProviderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProviderService {

  private final ProviderRepository providerRepository;

  @Autowired
  public ProviderService(ProviderRepository providerRepository) {
    this.providerRepository = providerRepository;
  }

  public Provider saveProvider(Provider provider) {
    return providerRepository.save(provider);
  }

  public Provider getProviderById(int id) {
    return providerRepository.findById(id).orElse(null);
  }
}
