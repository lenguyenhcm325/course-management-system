package com.github.lenguyenhcm325.coursemanagementsystembackend.controller;

import com.github.lenguyenhcm325.coursemanagementsystembackend.entity.Provider;
import com.github.lenguyenhcm325.coursemanagementsystembackend.service.ProviderService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/providers")
public class ProviderController {

  private final ProviderService providerService;

  @Autowired
  public ProviderController(ProviderService providerService) {
    this.providerService = providerService;
  }

  @PostMapping
  public ResponseEntity<Provider> createProvider(@Valid @RequestBody Provider provider) {
    Provider createdProvider = providerService.saveProvider(provider);
    return new ResponseEntity<>(createdProvider, HttpStatus.CREATED);
  }

  @GetMapping("/{id}")
  public ResponseEntity<Provider> getProviderById(@PathVariable int id) {
    Provider provider = providerService.getProviderById(id);
    if (provider != null) {
      return new ResponseEntity<>(provider, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @GetMapping
  public ResponseEntity<List<Provider>> getAllProviders() {
    List<Provider> providers = providerService.getAllProviders();
    return new ResponseEntity<>(providers, HttpStatus.OK);
  }

  @PutMapping("/{id}")
  public ResponseEntity<Provider> updateProvider(
      @PathVariable int id, @Valid @RequestBody Provider updatedProvider) {
    Provider existingProvider = providerService.getProviderById(id);
    if (existingProvider != null) {
      Provider updated = providerService.updateProviderById(id, updatedProvider);
      return new ResponseEntity<>(updated, HttpStatus.OK);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteProvider(@PathVariable int id) {
    Provider existingProvider = providerService.getProviderById(id);
    if (existingProvider != null) {
      providerService.deleteProviderById(id);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } else {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
  }
}
